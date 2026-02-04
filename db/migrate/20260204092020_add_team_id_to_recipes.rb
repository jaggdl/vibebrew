class AddTeamIdToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_reference :recipes, :team, foreign_key: true, null: true
  end
end
