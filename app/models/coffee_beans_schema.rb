class CoffeeBeansSchema < RubyLLM::Schema
  string :brand, description: "The name of the coffee brand"
  string :origin, description: "The region or country where the coffee is sourced"
  array :variety, of: CoffeeBeanVarietySchema, description: "The varieties of coffee bean with their percentages"
  array :process, of: :string, description: "The methods used to process the beans (e.g., washed, natural, honey)"
  array :tasting_notes, of: :string, description: "Flavor profiles or characteristics of the coffee"
  string :producer, description: "The name of the producer"
  string :notes, description: "Additional observations or preferences"
end
