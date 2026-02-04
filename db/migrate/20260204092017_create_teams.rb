class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
