module Saas
  class Plan < ApplicationRecord
    TIERS = {
      free: {
        price_cents: 0,
        coffee_bean_limit: 5,
        recipe_limit: 10,
        storage_limit_gb: 0.1,
        ai_generations_per_month: 5
      },
      starter: {
        price_cents: 999,
        coffee_bean_limit: 25,
        recipe_limit: 100,
        storage_limit_gb: 1,
        ai_generations_per_month: 50
      },
      pro: {
        price_cents: 2499,
        coffee_bean_limit: 100,
        recipe_limit: 500,
        storage_limit_gb: 10,
        ai_generations_per_month: 200
      },
      enterprise: {
        price_cents: 9999,
        coffee_bean_limit: Float::INFINITY,
        recipe_limit: Float::INFINITY,
        storage_limit_gb: Float::INFINITY,
        ai_generations_per_month: Float::INFINITY
      }
    }.freeze

    has_many :subscriptions, class_name: "Saas::Subscription"

    validates :name, presence: true, uniqueness: true
    validates :stripe_price_id, presence: true, if: -> { price_cents.to_i > 0 }

    def self.free
      find_or_create_by!(name: "free") do |plan|
        plan.price_cents = TIERS[:free][:price_cents]
        plan.coffee_bean_limit = TIERS[:free][:coffee_bean_limit]
        plan.recipe_limit = TIERS[:free][:recipe_limit]
        plan.storage_limit_gb = TIERS[:free][:storage_limit_gb]
        plan.ai_generations_per_month = TIERS[:free][:ai_generations_per_month]
      end
    end

    def self.starter
      find_by(name: "starter")
    end

    def self.pro
      find_by(name: "pro")
    end

    def self.enterprise
      find_by(name: "enterprise")
    end

    def free?
      name == "free"
    end

    def unlimited?
      name == "enterprise"
    end

    def storage_limit_bytes
      (storage_limit_gb * 1024 * 1024 * 1024).to_i
    end

    def display_price
      return "Free" if price_cents.zero?
      "$#{price_cents / 100}/month"
    end
  end
end
