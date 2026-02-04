class CreateSaasMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :saas_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: { to_table: :saas_teams }
      t.string :role, null: false, default: "member"

      t.timestamps
    end

    add_index :saas_memberships, [ :user_id, :team_id ], unique: true
    add_index :saas_memberships, :role
  end
end
