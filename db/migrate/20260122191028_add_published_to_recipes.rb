class AddPublishedToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :published, :boolean, default: false, null: false
  end
end
