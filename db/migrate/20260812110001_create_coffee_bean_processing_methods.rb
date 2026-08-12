class CreateCoffeeBeanProcessingMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :coffee_bean_processing_methods do |t|
      t.references :coffee_bean, null: false, foreign_key: true
      t.references :processing_method, null: false, foreign_key: true

      t.timestamps
    end

    add_index :coffee_bean_processing_methods, [ :coffee_bean_id, :processing_method_id ], unique: true
  end
end
