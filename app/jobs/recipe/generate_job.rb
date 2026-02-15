class Recipe::GenerateJob < ApplicationJob
  queue_as :default

  def perform(recipe)
    recipe.generate_now
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Recipe with id #{recipe.id} not found"
  end
end
