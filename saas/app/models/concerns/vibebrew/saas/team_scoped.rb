module Vibebrew
  module Saas
    module TeamScoped
      extend ActiveSupport::Concern

      included do
        belongs_to :team, class_name: "Vibebrew::Saas::Team", optional: true

        default_scope { where(team: Current.team) if Current.respond_to?(:team) && Current.team.present? }

        before_validation :assign_current_team, on: :create

        private

        def assign_current_team
          self.team ||= Current.team if Current.respond_to?(:team)
        end
      end
    end
  end
end
