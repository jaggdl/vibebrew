class CreateSaasSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :saas_subscriptions do |t|
      t.references :team, null: false, foreign_key: { to_table: :saas_teams }, index: { unique: true }
      t.references :plan, null: false, foreign_key: { to_table: :saas_plans }
      t.string :stripe_subscription_id, index: { unique: true }
      t.string :status, null: false, default: "active"
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.boolean :cancel_at_period_end, default: false

      t.timestamps
    end

    add_index :saas_subscriptions, :status
  end
end
