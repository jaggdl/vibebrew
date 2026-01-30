class GenerateRecipeJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)
    brewing_method = BrewingMethods.for(recipe.recipe_type).new(recipe.coffee_bean, recipe)

    chat_record = Chat.create!(model: "gpt-5")
    response = chat_record.with_schema(brewing_method.schema).ask(brewing_method.prompt)

    recipe.update!(response.content)
    recipe.regenerate_slug!

    broadcast_updates(recipe)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Recipe with id #{recipe_id} not found"
  rescue StandardError => e
    Rails.logger.error "Failed to generate recipe #{recipe_id}: #{e.message}"
    raise
  end

  private

  def broadcast_updates(recipe)
    Turbo::StreamsChannel.broadcast_refresh_to(recipe)
    Turbo::StreamsChannel.broadcast_refresh_to(recipe.coffee_bean)
  end
end
