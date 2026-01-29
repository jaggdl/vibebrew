class CreateCoffeeBeanRotations < ActiveRecord::Migration[8.0]
  def change
    create_table :coffee_bean_rotations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :coffee_bean, null: false, foreign_key: true

      t.timestamps
    end

    add_index :coffee_bean_rotations, [ :user_id, :coffee_bean_id ], unique: true
  end
end
