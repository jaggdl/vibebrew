class CoffeeBeansSchema < RubyLLM::Schema
  string :brand, description: "The name of the coffee brand"
  string :origin, description: "The region or country where the coffee is sourced"
  array :variety, of: :string, description: "The types of coffee bean (e.g., Arabica, Typica, Bourbon)"
  array :process, of: :string, description: "The methods used to process the beans (e.g., washed, natural, honey)"
  array :tasting_notes, of: :string, description: "Flavor profiles or characteristics of the coffee"
  string :producer, description: "The name of the producer"
  string :notes, description: "Additional observations or preferences"
end
