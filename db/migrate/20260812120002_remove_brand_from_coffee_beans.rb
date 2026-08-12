class RemoveBrandFromCoffeeBeans < ActiveRecord::Migration[8.0]
  def change
    remove_column :coffee_beans, :brand, :string
  end
end
