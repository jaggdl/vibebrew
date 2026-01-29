class CreateFavoriteCoffeeBeans < ActiveRecord::Migration[8.0]
  def change
    create_table :favorite_coffee_beans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :coffee_bean, null: false, foreign_key: true

      t.timestamps
    end

    add_index :favorite_coffee_beans, [ :user_id, :coffee_bean_id ], unique: true
  end
end
