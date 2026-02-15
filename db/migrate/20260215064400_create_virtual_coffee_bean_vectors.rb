class CreateVirtualCoffeeBeanVectors < ActiveRecord::Migration[8.0]
  def change
    create_table :coffee_bean_vectors do |t|
      t.references :coffee_bean, null: false, foreign_key: true, index: { unique: true }
      t.json :embedding, null: false
      t.timestamps
    end
  end
end
