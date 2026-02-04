class AddTeamIdToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_reference :recipes, :team, foreign_key: { to_table: :saas_teams }, null: true
  end
end
