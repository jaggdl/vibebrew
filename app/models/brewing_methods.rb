module BrewingMethods
  REGISTRY = {
    "aeropress" => BrewingMethods::Aeropress,
    "v60" => BrewingMethods::V60,
    "french_press" => BrewingMethods::FrenchPress,
    "moka" => BrewingMethods::Moka,
    "espresso" => BrewingMethods::Espresso
  }.freeze

  class << self
    def all
      REGISTRY.keys
    end

    def for(type)
      REGISTRY[type] || raise(ArgumentError, "Unknown brewing method: #{type}")
    end

    def label(type)
      self.for(type).label
    end

    def icon(type)
      self.for(type).icon
    end

    def options_for_select
      REGISTRY.map { |type, klass| [ klass.label, type ] }
    end
  end
end
