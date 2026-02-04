module Vibebrew
  module Saas
    class WebhooksController < ::ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :require_authentication, if: -> { defined?(super) }

      def stripe
        payload = request.body.read
        sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

        begin
          event = Stripe::Webhook.construct_event(
            payload,
            sig_header,
            Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV["STRIPE_WEBHOOK_SECRET"]
          )
        rescue JSON::ParserError
          head :bad_request
          return
        rescue Stripe::SignatureVerificationError
          head :bad_request
          return
        end

        handle_event(event)
        head :ok
      end

      private

      def handle_event(event)
        case event.type
        when "checkout.session.completed"
          handle_checkout_completed(event.data.object)
        when "customer.subscription.created"
          handle_subscription_created(event.data.object)
        when "customer.subscription.updated"
          handle_subscription_updated(event.data.object)
        when "customer.subscription.deleted"
          handle_subscription_deleted(event.data.object)
        when "invoice.payment_failed"
          handle_payment_failed(event.data.object)
        when "invoice.payment_succeeded"
          handle_payment_succeeded(event.data.object)
        end
      end

      def handle_checkout_completed(session)
        return unless session.metadata&.team_id.present?

        team = ::Team.find_by(id: session.metadata.team_id)
        return unless team

        if session.subscription.present?
          stripe_subscription = Stripe::Subscription.retrieve(session.subscription)
          plan_name = session.metadata.plan_name

          subscription = team.subscription || team.build_subscription
          subscription.plan_name = plan_name if plan_name.present?
          subscription.sync_from_stripe!(stripe_subscription)
        end
      end

      def handle_subscription_created(stripe_subscription)
        team = find_team_by_customer(stripe_subscription.customer)
        return unless team

        subscription = team.subscription || team.build_subscription
        subscription.plan_name ||= find_plan_name_by_price(stripe_subscription.items.data.first&.price&.id) || "free"
        subscription.sync_from_stripe!(stripe_subscription)
      end

      def handle_subscription_updated(stripe_subscription)
        subscription = Vibebrew::Saas::Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
        return unless subscription

        # Check if plan changed
        new_price_id = stripe_subscription.items.data.first&.price&.id
        if new_price_id.present?
          new_plan_name = find_plan_name_by_price(new_price_id)
          subscription.plan_name = new_plan_name if new_plan_name.present?
        end

        subscription.sync_from_stripe!(stripe_subscription)
      end

      def handle_subscription_deleted(stripe_subscription)
        subscription = Vibebrew::Saas::Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
        return unless subscription

        subscription.update!(status: :canceled)
      end

      def handle_payment_failed(invoice)
        return unless invoice.subscription.present?

        subscription = Vibebrew::Saas::Subscription.find_by(stripe_subscription_id: invoice.subscription)
        return unless subscription

        subscription.update!(status: :past_due)
      end

      def handle_payment_succeeded(invoice)
        return unless invoice.subscription.present?

        subscription = Vibebrew::Saas::Subscription.find_by(stripe_subscription_id: invoice.subscription)
        return unless subscription

        subscription.update!(status: :active) if subscription.past_due?
      end

      def find_team_by_customer(customer_id)
        ::Team.find_by(stripe_customer_id: customer_id)
      end

      def find_plan_name_by_price(price_id)
        plan = Vibebrew::Saas::Plan.find_by_stripe_price_id(price_id)
        plan&.name&.to_s
      end
    end
  end
end
