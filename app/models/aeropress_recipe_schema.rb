class AeropressRecipeSchema < RubyLLM::Schema
  string :name, description: "Name of the recipe", required: true
  string :description, description: "Additional observations or preferences", required: true
  boolean :inverted_method, description: "If the brew requires the inverted Aeropress method"
  string :grind_size, description: "The grind size of the coffee (e.g., Medium Grind)", enum: [ "extra fine", "fine", "medium", "coarse", "extra coarse" ]
  number :coffee_weight, description: "The weight of coffee in grams", minimum: 0
  number :water_weight, description: "The weight of water in grams", minimum: 0
  number :water_temperature, description: "The temperature of water in Celsius", minimum: 0
  array :steps, description: "The brewing steps" do
    object do
      string :description, description: "Description of the step", required: true
      number :time, description: "Time duration for the step in seconds", minimum: 0
    end
  end
end
