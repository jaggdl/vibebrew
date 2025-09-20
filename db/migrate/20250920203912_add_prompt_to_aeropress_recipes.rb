class AddPromptToAeropressRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :aeropress_recipes, :prompt, :text
  end
end
