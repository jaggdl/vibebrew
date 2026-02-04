class AddInviteCodeToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :invite_code, :string
    add_index :teams, :invite_code, unique: true

    reversible do |dir|
      dir.up do
        Team.find_each do |team|
          team.update_column(:invite_code, SecureRandom.hex(16))
        end
      end
    end
  end
end
