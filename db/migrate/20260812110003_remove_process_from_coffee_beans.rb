class RemoveProcessFromCoffeeBeans < ActiveRecord::Migration[8.0]
  def change
    remove_column :coffee_beans, :process, :json
  end
end
