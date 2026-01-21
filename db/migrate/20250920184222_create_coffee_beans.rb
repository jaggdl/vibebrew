class CreateCoffeeBeans < ActiveRecord::Migration[8.0]
  def change
    create_table :coffee_beans do |t|
      t.references :user, null: false, foreign_key: true
      t.string :brand
      t.string :origin
      t.json :variety, default: []
      t.json :process, default: []
      t.json :tasting_notes, default: []
      t.string :producer
      t.text :notes

      t.timestamps
    end
  end
end
