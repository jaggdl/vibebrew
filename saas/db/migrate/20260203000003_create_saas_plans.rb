class CreateSaasPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :saas_plans do |t|
      t.string :name, null: false, index: { unique: true }
      t.integer :price_cents, null: false, default: 0
      t.string :stripe_price_id, index: true
      t.integer :coffee_bean_limit, null: false, default: 5
      t.integer :recipe_limit, null: false, default: 10
      t.decimal :storage_limit_gb, null: false, default: 0.1, precision: 10, scale: 2
      t.integer :ai_generations_per_month, null: false, default: 5

      t.timestamps
    end
  end
end
