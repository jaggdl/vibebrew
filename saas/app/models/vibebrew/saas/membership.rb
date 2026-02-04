module Vibebrew
  module Saas
    class Membership < ApplicationRecord
      belongs_to :user
      belongs_to :team, class_name: "Vibebrew::Saas::Team"

      enum :role, { member: "member", admin: "admin", owner: "owner" }

      validates :user_id, uniqueness: { scope: :team_id }
      validates :role, presence: true

      def can_manage_users?
        admin? || owner?
      end

      def can_manage_settings?
        owner?
      end

      def can_manage_billing?
        owner?
      end
    end
  end
end
