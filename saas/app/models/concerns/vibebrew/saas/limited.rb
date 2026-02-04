module Vibebrew
  module Saas
    module Limited
      extend ActiveSupport::Concern

      class LimitExceededError < StandardError
        attr_reader :resource_type, :current_count, :limit

        def initialize(resource_type:, current_count:, limit:)
          @resource_type = resource_type
          @current_count = current_count
          @limit = limit
          super("#{resource_type.to_s.humanize} limit exceeded: #{current_count}/#{limit}")
        end
      end

      def can_create_coffee_bean?
        return true if plan.unlimited?
        coffee_beans.count < plan.coffee_bean_limit
      end

      def can_create_recipe?
        return true if plan.unlimited?
        recipes.count < plan.recipe_limit
      end

      def can_upload_storage?(bytes)
        return true if plan.unlimited?
        storage_used + bytes <= plan.storage_limit_bytes
      end

      def can_use_ai_generation?
        return true if plan.unlimited?
        ai_generations_this_month < plan.ai_generations_per_month
      end

      def storage_used
        # Calculate total storage used by attachments
        coffee_beans.includes(images_attachments: :blob).sum { |cb| cb.images.sum(&:byte_size) }
      end

      def ai_generations_this_month
        # Track AI generations for the current billing period
        start_of_month = Time.current.beginning_of_month
        coffee_beans.where("created_at >= ?", start_of_month).count +
          recipes.where("created_at >= ?", start_of_month).count
      end

      def check_coffee_bean_limit!
        return if can_create_coffee_bean?
        raise LimitExceededError.new(
          resource_type: :coffee_beans,
          current_count: coffee_beans.count,
          limit: plan.coffee_bean_limit
        )
      end

      def check_recipe_limit!
        return if can_create_recipe?
        raise LimitExceededError.new(
          resource_type: :recipes,
          current_count: recipes.count,
          limit: plan.recipe_limit
        )
      end

      def check_storage_limit!(bytes)
        return if can_upload_storage?(bytes)
        raise LimitExceededError.new(
          resource_type: :storage,
          current_count: storage_used,
          limit: plan.storage_limit_bytes
        )
      end

      def check_ai_generation_limit!
        return if can_use_ai_generation?
        raise LimitExceededError.new(
          resource_type: :ai_generations,
          current_count: ai_generations_this_month,
          limit: plan.ai_generations_per_month
        )
      end

      def usage_stats
        {
          coffee_beans: { current: coffee_beans.count, limit: plan.coffee_bean_limit },
          recipes: { current: recipes.count, limit: plan.recipe_limit },
          storage: { current: storage_used, limit: plan.storage_limit_bytes },
          ai_generations: { current: ai_generations_this_month, limit: plan.ai_generations_per_month }
        }
      end
    end
  end
end
