class CreateSaasTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :saas_teams do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :stripe_customer_id, index: true

      t.timestamps
    end
  end
end
