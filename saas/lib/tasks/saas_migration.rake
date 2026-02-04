namespace :saas do
  namespace :migrate do
    desc "Migrate self-hosted data to SaaS (create teams for existing users)"
    task data: :environment do
      unless Vibebrew.saas?
        puts "Error: SaaS mode is not enabled. Run 'bin/rails saas:enable' first."
        exit 1
      end

      ActiveRecord::Base.transaction do
        migrated_users = 0
        migrated_coffee_beans = 0

        User.find_each do |user|
          # Skip if user already has a team
          next if user.teams.any?

          # Create a team for each user
          team = Vibebrew::Saas::Team.create!(
            name: "#{user.name}'s Team"
          )

          # Add user as owner
          Vibebrew::Saas::Membership.create!(
            user: user,
            team: team,
            role: :owner
          )

          # Create free subscription for the team
          Vibebrew::Saas::Subscription.create!(
            team: team,
            plan_name: "free",
            status: :active
          )

          # Assign user's coffee beans to their team
          user.coffee_beans.unscoped.where(team_id: nil).update_all(team_id: team.id)
          migrated_coffee_beans += user.coffee_beans.count

          # Assign recipes to team
          Recipe.unscoped.joins(:coffee_bean).where(coffee_beans: { user_id: user.id }, team_id: nil).update_all(team_id: team.id)

          migrated_users += 1
          puts "Migrated user: #{user.email_address} -> Team: #{team.name}"
        end

        puts "\nMigration complete!"
        puts "Users migrated: #{migrated_users}"
        puts "Coffee beans assigned: #{migrated_coffee_beans}"
      end
    end
  end
end
