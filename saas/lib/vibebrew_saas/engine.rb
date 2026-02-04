module VibebrewSaas
  class Engine < ::Rails::Engine
    isolate_namespace Saas

    initializer "vibebrew_saas.assets" do |app|
      app.config.paths["db/migrate"].concat(config.paths["db/migrate"].expanded)
    end

    config.to_prepare do
      next unless defined?(VibeBrew) && VibeBrew.saas?

      # Extend User with team associations
      User.class_eval do
        has_many :memberships, class_name: "Saas::Membership", dependent: :destroy
        has_many :teams, through: :memberships, class_name: "Saas::Team"
      end

      # Inject team scoping into models
      CoffeeBean.include(Saas::TeamScoped)
      Recipe.include(Saas::TeamScoped)

      # Extend Current with team
      Current.include(Saas::CurrentTeam)

      # Add team context to ApplicationController
      ApplicationController.include(Saas::SetsCurrentTeam)

      # Add limit enforcement to controllers
      CoffeeBeansController.include(Saas::EnforcesLimits)
      CoffeeBeansController.before_action :enforce_coffee_bean_limit!, only: [ :create ]

      RecipesController.include(Saas::EnforcesLimits)
      RecipesController.before_action :enforce_recipe_limit!, only: [ :create ]
    end
  end
end
