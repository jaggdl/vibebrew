class CreateCoffeeBeanVarieties < ActiveRecord::Migration[8.0]
  def change
    create_table :coffee_bean_varieties do |t|
      t.references :coffee_bean, null: false, foreign_key: true
      t.references :variety, null: false, foreign_key: true
      t.integer :percentage

      t.timestamps
    end

    add_index :coffee_bean_varieties, [ :coffee_bean_id, :variety_id ], unique: true
  end
end
