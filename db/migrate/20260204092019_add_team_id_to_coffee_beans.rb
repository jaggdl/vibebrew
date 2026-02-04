class AddTeamIdToCoffeeBeans < ActiveRecord::Migration[8.0]
  def change
    add_reference :coffee_beans, :team, foreign_key: true, null: true
  end
end
