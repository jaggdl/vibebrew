class CreateProcessingMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :processing_methods do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :processing_methods, :name, unique: true
  end
end
