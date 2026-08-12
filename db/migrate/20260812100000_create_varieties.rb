class CreateVarieties < ActiveRecord::Migration[8.0]
  def change
    create_table :varieties do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :varieties, :name, unique: true
  end
end
