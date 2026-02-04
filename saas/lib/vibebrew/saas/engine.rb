module Vibebrew
  module Saas
    class Engine < ::Rails::Engine
      isolate_namespace Vibebrew::Saas

      initializer "vibebrew_saas.assets" do |app|
        app.config.paths["db/migrate"].concat(config.paths["db/migrate"].expanded)
      end


      initializer "vibebrew_saas.mount" do |app|
        app.routes.append do
          mount Vibebrew::Saas::Engine => "/", as: "saas"
        end
      end

      config.to_prepare do
        # Extend User with team associations
        User.class_eval do
          has_many :memberships, class_name: "Vibebrew::Saas::Membership", dependent: :destroy
          has_many :teams, through: :memberships, class_name: "Vibebrew::Saas::Team"
        end

        # Inject team scoping into models
        CoffeeBean.include(Vibebrew::Saas::TeamScoped)
        Recipe.include(Vibebrew::Saas::TeamScoped)

        # Extend Current with team
        Current.include(Vibebrew::Saas::CurrentTeam)

        # Add team context to ApplicationController
        ApplicationController.include(Vibebrew::Saas::SetsCurrentTeam)

        # Add limit enforcement to controllers
        CoffeeBeansController.include(Vibebrew::Saas::EnforcesLimits)
        CoffeeBeansController.before_action :enforce_coffee_bean_limit!, only: [ :create ]

        RecipesController.include(Vibebrew::Saas::EnforcesLimits)
        RecipesController.before_action :enforce_recipe_limit!, only: [ :create ]
      end
    end
  end
end
