module Vibebrew
  module Saas
    module CreatesTeamSubscription
      extend ActiveSupport::Concern

      included do
        after_action :create_free_subscription, only: :create, if: :team_created_successfully?
      end

      private

      def team_created_successfully?
        response.successful? && @team.persisted?
      end

      def create_free_subscription
        Vibebrew::Saas::Subscription.create!(
          team: @team,
          plan_name: "free",
          status: :active
        )
      end
    end
  end
end
