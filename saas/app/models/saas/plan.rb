module Saas
  class Plan
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

    attr_reader :name

    def initialize(name)
      @name = name.to_sym
      raise ArgumentError, "Unknown plan: #{name}" unless TIERS.key?(@name)
    end

    def self.all
      TIERS.keys.map { |name| new(name) }
    end

    def self.paid
      all.reject(&:free?)
    end

    def self.free
      new(:free)
    end

    def self.starter
      new(:starter)
    end

    def self.pro
      new(:pro)
    end

    def self.enterprise
      new(:enterprise)
    end

    def self.find(name)
      new(name)
    end

    def self.find_by_stripe_price_id(price_id)
      return nil if price_id.blank?

      plan_name = TIERS.keys.find do |name|
        new(name).stripe_price_id == price_id
      end

      plan_name ? new(plan_name) : nil
    end

    def config
      TIERS[@name]
    end

    def price_cents
      config[:price_cents]
    end

    def coffee_bean_limit
      config[:coffee_bean_limit]
    end

    def recipe_limit
      config[:recipe_limit]
    end

    def storage_limit_gb
      config[:storage_limit_gb]
    end

    def ai_generations_per_month
      config[:ai_generations_per_month]
    end

    def storage_limit_bytes
      return Float::INFINITY if storage_limit_gb == Float::INFINITY
      (storage_limit_gb * 1024 * 1024 * 1024).to_i
    end

    def stripe_price_id
      return nil if free?
      ENV["STRIPE_PRICE_ID_#{@name.to_s.upcase}"]
    end

    def free?
      @name == :free
    end

    def unlimited?
      @name == :enterprise
    end

    def display_price
      return "Free" if price_cents.zero?
      "$#{price_cents / 100}/month"
    end

    def display_name
      @name.to_s.titleize
    end

    def ==(other)
      other.is_a?(Plan) && other.name == @name
    end

    def to_s
      @name.to_s
    end
  end
end
