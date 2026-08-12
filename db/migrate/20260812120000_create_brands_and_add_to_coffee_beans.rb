class CreateBrandsAndAddToCoffeeBeans < ActiveRecord::Migration[8.0]
  def change
    create_table :brands do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :brands, :name, unique: true

    add_reference :coffee_beans, :brand, foreign_key: true
  end
end
