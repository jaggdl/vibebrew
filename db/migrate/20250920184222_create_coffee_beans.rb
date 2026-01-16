class CreateCoffeeBeans < ActiveRecord::Migration[8.0]
  def change
    create_table :coffee_beans do |t|
      t.references :user, null: false, foreign_key: true
      t.string :brand
      t.string :origin
      t.string :variety
      t.string :process
      t.string :tasting_notes
      t.string :producer
      t.text :notes

      t.timestamps
    end
  end
end
