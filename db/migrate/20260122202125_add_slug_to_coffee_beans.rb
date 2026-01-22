class AddSlugToCoffeeBeans < ActiveRecord::Migration[8.0]
  def change
    add_column :coffee_beans, :slug, :string
    add_index :coffee_beans, :slug, unique: true
  end
end
