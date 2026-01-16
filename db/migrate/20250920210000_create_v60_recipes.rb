class CreateV60Recipes < ActiveRecord::Migration[8.0]
  def change
    create_table :v60_recipes do |t|
      t.references :coffee_bean, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :grind_size
      t.decimal :coffee_weight, precision: 8, scale: 2
      t.decimal :water_weight, precision: 8, scale: 2
      t.decimal :water_temperature, precision: 5, scale: 2
      t.json :steps
      t.text :prompt

      t.timestamps
    end
  end
end
