class RemoveRoleFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_index :users, :role
    remove_column :users, :role, :string
  end
end
