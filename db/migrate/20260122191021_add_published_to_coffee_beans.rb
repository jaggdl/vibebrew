class AddPublishedToCoffeeBeans < ActiveRecord::Migration[8.0]
  def change
    add_column :coffee_beans, :published, :boolean, default: false, null: false
  end
end
