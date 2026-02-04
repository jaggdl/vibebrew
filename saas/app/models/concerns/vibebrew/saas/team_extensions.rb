module Vibebrew
  module Saas
    module TeamExtensions
      extend ActiveSupport::Concern

      included do
        has_one :subscription, class_name: "Vibebrew::Saas::Subscription", dependent: :destroy
      end

      def plan
        subscription&.plan || Vibebrew::Saas::Plan.free
      end
    end
  end
end
