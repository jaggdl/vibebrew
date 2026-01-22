class ExtractCoffeeBeanInfoJob < ApplicationJob
  queue_as :default

  def perform(coffee_bean_id)
    coffee_bean = CoffeeBean.find(coffee_bean_id)
    return unless coffee_bean.images.attached?

    chat_record = Chat.create!(model: "gpt-5-mini")

    prompt = build_extraction_prompt(coffee_bean)

    image_blobs = coffee_bean.images.map(&:blob)

    response = chat_record.with_schema(CoffeeBeansSchema).ask(prompt, with: image_blobs)

    coffee_bean.update!(response.content)

    broadcast_updates(coffee_bean)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "CoffeeBean with id #{coffee_bean_id} not found"
  rescue StandardError => e
    Rails.logger.error "Failed to extract coffee bean info for #{coffee_bean_id}: #{e.message}"
    raise
  end

  private

  def broadcast_updates(coffee_bean)
    # Broadcast to the show page (subscribed to the specific coffee_bean)
    Turbo::StreamsChannel.broadcast_replace_to(
      coffee_bean,
      target: ActionView::RecordIdentifier.dom_id(coffee_bean, :details),
      partial: "coffee_beans/details",
      locals: { coffee_bean: coffee_bean }
    )

    # Broadcast to the index page (subscribed to "coffee_beans")
    Turbo::StreamsChannel.broadcast_replace_to(
      "coffee_beans",
      target: ActionView::RecordIdentifier.dom_id(coffee_bean, :info),
      partial: "coffee_beans/coffee_bean_info",
      locals: { coffee_bean: coffee_bean }
    )

    # Remove the loading overlay on the index page
    Turbo::StreamsChannel.broadcast_replace_to(
      "coffee_beans",
      target: ActionView::RecordIdentifier.dom_id(coffee_bean, :loading),
      partial: "coffee_beans/coffee_bean_loading",
      locals: { coffee_bean: coffee_bean }
    )
  end

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
      All the information should be in English.
    PROMPT
  end
end
