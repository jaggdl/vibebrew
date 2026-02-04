module Saas
  class CheckoutController < ApplicationController
    before_action :require_billing_access, except: [ :new ]

    def new
      @plans = Saas::Plan.paid
      @current_plan = Current.team&.plan
    end

    def create
      plan = Saas::Plan.find(params[:plan_name])

      if plan.free?
        redirect_to root_path, alert: "Cannot checkout for free plan"
        return
      end

      if plan.stripe_price_id.blank?
        redirect_to root_path, alert: "Stripe price not configured for this plan"
        return
      end

      session = create_checkout_session(plan)
      redirect_to session.url, allow_other_host: true
    end

    def success
      session_id = params[:session_id]

      if session_id.present?
        stripe_session = Stripe::Checkout::Session.retrieve(session_id)
        handle_successful_checkout(stripe_session)
      end

      redirect_to root_path, notice: "Successfully upgraded your plan!"
    end

    def cancel
      redirect_to saas.pricing_path, notice: "Checkout cancelled"
    end

    private

    def create_checkout_session(plan)
      team = Current.team

      # Ensure team has a Stripe customer
      if team.stripe_customer_id.blank?
        customer = Stripe::Customer.create(
          email: Current.user.email_address,
          name: team.name,
          metadata: { team_id: team.id }
        )
        team.update!(stripe_customer_id: customer.id)
      end

      Stripe::Checkout::Session.create(
        customer: team.stripe_customer_id,
        payment_method_types: [ "card" ],
        line_items: [ {
          price: plan.stripe_price_id,
          quantity: 1
        } ],
        mode: "subscription",
        success_url: saas.checkout_success_url(session_id: "{CHECKOUT_SESSION_ID}"),
        cancel_url: saas.checkout_cancel_url,
        metadata: {
          team_id: team.id,
          plan_name: plan.name.to_s
        }
      )
    end

    def handle_successful_checkout(stripe_session)
      team_id = stripe_session.metadata.team_id
      plan_name = stripe_session.metadata.plan_name

      team = Saas::Team.find(team_id)
      plan = Saas::Plan.find(plan_name)

      stripe_subscription = Stripe::Subscription.retrieve(stripe_session.subscription)

      subscription = team.subscription || team.build_subscription
      subscription.plan = plan
      subscription.sync_from_stripe!(stripe_subscription)
    end
  end
end
