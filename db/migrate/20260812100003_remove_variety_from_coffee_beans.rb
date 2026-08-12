class RemoveVarietyFromCoffeeBeans < ActiveRecord::Migration[8.0]
  def change
    remove_column :coffee_beans, :variety, :json
  end
end
