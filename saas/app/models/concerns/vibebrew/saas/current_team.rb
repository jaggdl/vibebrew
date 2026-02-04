module Vibebrew
  module Saas
    module CurrentTeam
      extend ActiveSupport::Concern

      included do
        attribute :team
        attribute :membership

        def team_role
          membership&.role
        end

        def can_manage_users?
          membership&.can_manage_users?
        end

        def can_manage_settings?
          membership&.can_manage_settings?
        end

        def can_manage_billing?
          membership&.can_manage_billing?
        end
      end
    end
  end
end
