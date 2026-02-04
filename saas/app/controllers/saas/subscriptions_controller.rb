module Saas
  class SubscriptionsController < ApplicationController
    before_action :require_billing_access

    def show
      @subscription = Current.team.subscription
      @plan = Current.team.plan
      @usage = Current.team.usage_stats
    end

    def destroy
      subscription = Current.team.subscription

      if subscription&.stripe_subscription_id.present?
        subscription.cancel!
        redirect_to saas.subscription_path, notice: "Your subscription will be cancelled at the end of the billing period"
      else
        redirect_to saas.subscription_path, alert: "No active subscription to cancel"
      end
    end

    def reactivate
      subscription = Current.team.subscription

      if subscription&.cancel_at_period_end?
        subscription.reactivate!
        redirect_to saas.subscription_path, notice: "Your subscription has been reactivated"
      else
        redirect_to saas.subscription_path, alert: "Subscription is not scheduled for cancellation"
      end
    end

    def portal
      team = Current.team

      if team.stripe_customer_id.blank?
        redirect_to saas.subscription_path, alert: "No billing account found"
        return
      end

      portal_session = Stripe::BillingPortal::Session.create(
        customer: team.stripe_customer_id,
        return_url: saas.subscription_url
      )

      redirect_to portal_session.url, allow_other_host: true
    end
  end
end
