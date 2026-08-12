module CoffeeBean::InfoExtraction
  extend ActiveSupport::Concern

  def extract_info_later
    CoffeeBean::ExtractInfoJob.perform_later(self)
  end

  def extract_info_now
    return unless images.attached?

    chat_record = Chat.create!(model: "gpt-5-mini")
    prompt = build_extraction_prompt
    image_blobs = images.map(&:blob)

    response = chat_record.with_schema(CoffeeBeansSchema).ask(prompt, with: image_blobs)

    extracted = response.content.to_h.deep_symbolize_keys
    variety_data = extracted.delete(:variety)

    update!(extracted)
    apply_varieties(variety_data)
    regenerate_slug!

    broadcast_extraction_updates
  rescue StandardError => e
    Rails.logger.error "Failed to extract coffee bean info for #{id}: #{e.message}"
    raise
  end

  private

  def broadcast_extraction_updates
    Turbo::StreamsChannel.broadcast_refresh_to(self)
    Turbo::StreamsChannel.broadcast_refresh_to("coffee_beans")
  end

  def apply_varieties(varieties)
    coffee_bean_varieties.destroy_all

    Array(varieties).each do |entry|
      name = entry[:name].to_s.strip
      next if name.blank?

      variety = Variety.find_or_create_by!(name: name)
      percentage = entry[:percentage].presence

      coffee_bean_varieties.create!(variety: variety, percentage: percentage)
    end
  end

  def build_extraction_prompt
    image_count = images.count
    known_varieties = Variety.pluck(:name).sort.map { |v| "- #{v}" }.join("\n")

    <<~PROMPT
      I have #{image_count} image(s) of a coffee bean package or label. Please analyze the image(s) and extract the following information:

      - Brand: The name of the coffee brand
      - Origin: The region or country where the coffee is sourced
      - Variety: Each type of coffee bean listed (e.g., Arabica, Typica, Bourbon), along with its percentage of the blend when the package states it (e.g., "80% Typica" -> name "Typica", percentage 80)
      - Process: The method used to process the beans (e.g., washed, natural, honey)
      - Tasting notes: Flavor profiles or characteristics of the coffee
      - Producer: The name of the producer or farm
      - Notes: Any additional observations or information

      Guidelines:
      - All information must be in English.
      - Use the exact variety names from the list below whenever one of them appears on the package (normalize spelling, accents, and case to match). Omit percentages that come purely from the package wording unless they indicate a blend ratio.
      - Do not treat origins (e.g., Colombia, Costa Rica, Ethiopia) or processing styles (e.g., natural, Supernatural) as varieties.
      - If a variety on the package is not in the list, report its name in English spelling.
      - If any information is not visible or available, leave that field empty or null.
      - Focus on extracting accurate information directly from what you can see.

      Known varieties:
      #{known_varieties.empty? ? 'None recorded yet.' : known_varieties}
    PROMPT
  end
end
