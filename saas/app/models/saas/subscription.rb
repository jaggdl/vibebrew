module Saas
  class Subscription < ApplicationRecord
    belongs_to :team, class_name: "Saas::Team"

    enum :status, {
      active: "active",
      past_due: "past_due",
      canceled: "canceled",
      trialing: "trialing",
      incomplete: "incomplete"
    }

    validates :stripe_subscription_id, uniqueness: true, allow_nil: true
    validates :team_id, uniqueness: true
    validates :plan_name, presence: true, inclusion: { in: Saas::Plan::TIERS.keys.map(&:to_s) }

    scope :active_or_trialing, -> { where(status: [ :active, :trialing ]) }

    def plan
      Saas::Plan.new(plan_name)
    end

    def plan=(new_plan)
      self.plan_name = new_plan.is_a?(Saas::Plan) ? new_plan.name.to_s : new_plan.to_s
    end

    def active_or_trialing?
      active? || trialing?
    end

    def can_use_features?
      active_or_trialing? || plan.free?
    end

    def sync_from_stripe!(stripe_subscription)
      update!(
        stripe_subscription_id: stripe_subscription.id,
        status: stripe_subscription.status,
        current_period_start: Time.at(stripe_subscription.current_period_start),
        current_period_end: Time.at(stripe_subscription.current_period_end),
        cancel_at_period_end: stripe_subscription.cancel_at_period_end
      )
    end

    def cancel!
      return unless stripe_subscription_id.present?

      Stripe::Subscription.update(stripe_subscription_id, cancel_at_period_end: true)
      update!(cancel_at_period_end: true)
    end

    def reactivate!
      return unless stripe_subscription_id.present? && cancel_at_period_end?

      Stripe::Subscription.update(stripe_subscription_id, cancel_at_period_end: false)
      update!(cancel_at_period_end: false)
    end
  end
end
