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

    update!(response.content)
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

  def build_extraction_prompt
    image_count = images.count

    <<~PROMPT
      I have #{image_count} image(s) of a coffee bean package or label. Please analyze the image(s) and extract the following information:

      - Brand: The name of the coffee brand
      - Origin: The region or country where the coffee is sourced
      - Variety: The type of coffee bean (e.g., Arabica, Robusta, specific cultivar)
      - Process: The method used to process the beans (e.g., washed, natural, honey)
      - Tasting notes: Flavor profiles or characteristics of the coffee
      - Producer: The name of the producer or farm
      - Notes: Any additional observations or information

      If any information is not visible or available in the image(s), please leave that field empty or null.
      Focus on extracting accurate information directly from what you can see in the image(s).
      All the information should be in English.
    PROMPT
  end
end
