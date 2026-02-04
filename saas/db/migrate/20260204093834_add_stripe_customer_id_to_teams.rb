class AddStripeCustomerIdToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :stripe_customer_id, :string
    add_index :teams, :stripe_customer_id
  end
end
