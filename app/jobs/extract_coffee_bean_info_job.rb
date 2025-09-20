class ExtractCoffeeBeanInfoJob < ApplicationJob
  queue_as :default

  def perform(coffee_bean_id)
    coffee_bean = CoffeeBean.find(coffee_bean_id)
    return unless coffee_bean.images.attached?

    # Create a chat record for processing
    chat_record = Chat.create!(model: "gpt-4.1")

    # Build prompt with image information
    prompt = build_extraction_prompt(coffee_bean)

    # Get image blobs for RubyLLM
    image_blobs = coffee_bean.images.map(&:blob)

    # Extract structured information using the schema
    response = chat_record.with_schema(CoffeeBeansSchema).ask(prompt, with: image_blobs)

    # Update the coffee bean with extracted information
    coffee_bean.update!(response.content)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "CoffeeBean with id #{coffee_bean_id} not found"
  rescue StandardError => e
    Rails.logger.error "Failed to extract coffee bean info for #{coffee_bean_id}: #{e.message}"
    raise
  end

  private

  def build_extraction_prompt(coffee_bean)
    image_count = coffee_bean.images.count

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
    PROMPT
  end
end
