module Recipe::Generation
  extend ActiveSupport::Concern

  def generate_later
    Recipe::GenerateJob.perform_later(self)
  end

  def generate_now
    brewing_method = BrewingMethods.for(recipe_type).new(coffee_bean, self)

    chat_record = Chat.create!(model: "gpt-5")
    response = chat_record.with_schema(brewing_method.schema).ask(brewing_method.prompt)

    update!(response.content)
    regenerate_slug!

    broadcast_generation_updates
  rescue StandardError => e
    Rails.logger.error "Failed to generate recipe #{id}: #{e.message}"
    raise
  end

  private

  def broadcast_generation_updates
    Turbo::StreamsChannel.broadcast_refresh_to(self)
    Turbo::StreamsChannel.broadcast_refresh_to(coffee_bean)
  end
end
