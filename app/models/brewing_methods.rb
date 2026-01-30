module BrewingMethods
  REGISTRY = {
    "aeropress" => BrewingMethods::Aeropress,
    "v60" => BrewingMethods::V60
  }.freeze

  def self.all
    REGISTRY.keys
  end

  def self.for(type)
    REGISTRY[type] || raise(ArgumentError, "Unknown brewing method: #{type}")
  end

  def self.label(type)
    self.for(type).label
  end

  def self.icon(type)
    self.for(type).icon
  end

  def self.options_for_select
    REGISTRY.map { |type, klass| [klass.label, type] }
  end
end
