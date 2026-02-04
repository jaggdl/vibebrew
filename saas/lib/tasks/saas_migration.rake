namespace :saas do
  namespace :migrate do
    desc "Migrate self-hosted data to SaaS (create teams for existing users)"
    task data: :environment do
      unless VibeBrew.saas?
        puts "Error: SaaS mode is not enabled. Run 'bin/rails saas:enable' first."
        exit 1
      end

      ActiveRecord::Base.transaction do
        migrated_users = 0
        migrated_coffee_beans = 0
        migrated_recipes = 0

        User.find_each do |user|
          # Create a team for each user
          team = Saas::Team.create!(
            name: "#{user.name}'s Team"
          )

          # Add user as owner
          Saas::Membership.create!(
            user: user,
            team: team,
            role: :owner
          )

          # Create free subscription for the team
          Saas::Subscription.create!(
            team: team,
            plan: Saas::Plan.free,
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

    desc "Seed plans from TIERS configuration"
    task seed_plans: :environment do
      unless VibeBrew.saas?
        puts "Error: SaaS mode is not enabled."
        exit 1
      end

      Saas::Plan::TIERS.each do |name, config|
        plan = Saas::Plan.find_or_initialize_by(name: name.to_s)
        plan.assign_attributes(
          price_cents: config[:price_cents],
          coffee_bean_limit: config[:coffee_bean_limit] == Float::INFINITY ? 999999 : config[:coffee_bean_limit],
          recipe_limit: config[:recipe_limit] == Float::INFINITY ? 999999 : config[:recipe_limit],
          storage_limit_gb: config[:storage_limit_gb] == Float::INFINITY ? 999999 : config[:storage_limit_gb],
          ai_generations_per_month: config[:ai_generations_per_month] == Float::INFINITY ? 999999 : config[:ai_generations_per_month]
        )
        plan.save!
        puts "Created/Updated plan: #{name}"
      end

      puts "\nPlans seeded successfully!"
      puts "Don't forget to set stripe_price_id for paid plans."
    end
  end
end
