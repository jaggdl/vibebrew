module Saas
  module EnforcesLimits
    extend ActiveSupport::Concern

    included do
      rescue_from Saas::Limited::LimitExceededError, with: :handle_limit_exceeded
    end

    private

    def enforce_coffee_bean_limit!
      return unless VibeBrew.saas? && Current.team.present?
      Current.team.check_coffee_bean_limit!
    end

    def enforce_recipe_limit!
      return unless VibeBrew.saas? && Current.team.present?
      Current.team.check_recipe_limit!
    end

    def enforce_storage_limit!(bytes)
      return unless VibeBrew.saas? && Current.team.present?
      Current.team.check_storage_limit!(bytes)
    end

    def enforce_ai_generation_limit!
      return unless VibeBrew.saas? && Current.team.present?
      Current.team.check_ai_generation_limit!
    end

    def handle_limit_exceeded(exception)
      respond_to do |format|
        format.html do
          flash[:alert] = "You've reached your plan limit for #{exception.resource_type.to_s.humanize.downcase}. Please upgrade your plan to continue."
          redirect_back(fallback_location: root_path)
        end
        format.json do
          render json: {
            error: "limit_exceeded",
            resource_type: exception.resource_type,
            current: exception.current_count,
            limit: exception.limit,
            message: exception.message
          }, status: :payment_required
        end
      end
    end
  end
end
