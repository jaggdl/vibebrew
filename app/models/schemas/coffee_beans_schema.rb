class CoffeeBeansSchema < RubyLLM::Schema
  string :brand, description: "The name of the coffee brand"
  string :origin, description: "The region or country where the coffee is sourced"
  string :variety, description: "The type of coffee bean"
  string :process, description: "The method used to process the beans"
  string :tasting_notes, description: "Flavor profiles or characteristics of the coffee"
  string :producer, description: "The name of the producer"
  string :notes, description: "Additional observations or preferences", required: false
end
