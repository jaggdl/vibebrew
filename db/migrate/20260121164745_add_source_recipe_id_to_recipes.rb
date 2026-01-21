class AddSourceRecipeIdToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_reference :recipes, :source_recipe, foreign_key: { to_table: :recipes }
  end
end
