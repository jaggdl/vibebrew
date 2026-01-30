class RecipeSchema < RubyLLM::Schema
  string :name, description: "Name of the recipe", required: true
  string :description, description: "Additional observations or preferences", required: true
  string :grind_size, description: "The grind size of the coffee (e.g., Medium Grind)", enum: [ "extra fine", "fine", "medium", "coarse", "extra coarse" ]
  number :coffee_weight, description: "The weight of coffee in grams", minimum: 0
  number :water_weight, description: "The weight of water in grams", minimum: 0
  number :water_temperature, description: "The temperature of water in Celsius", minimum: 0
  array :steps, description: "The brewing steps", of: RecipeStepSchema
end
