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
        # Extend Team with SaaS-specific associations and methods
        Team.include(Vibebrew::Saas::TeamExtensions)

        # Extend TeamsController with SaaS-specific behavior
        TeamsController.include(Vibebrew::Saas::CreatesTeamSubscription)

        # Inject team scoping into models (only in SaaS mode)
        CoffeeBean.include(Vibebrew::Saas::TeamScoped) if Vibebrew.saas?
        Recipe.include(Vibebrew::Saas::TeamScoped) if Vibebrew.saas?

        # Add limit enforcement to controllers (only in SaaS mode)
        if Vibebrew.saas?
          CoffeeBeansController.include(Vibebrew::Saas::EnforcesLimits)
          CoffeeBeansController.before_action :enforce_coffee_bean_limit!, only: [ :create ]

          RecipesController.include(Vibebrew::Saas::EnforcesLimits)
          RecipesController.before_action :enforce_recipe_limit!, only: [ :create ]
        end
      end
    end
  end
end
