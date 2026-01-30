class RecipeStepSchema < RubyLLM::Schema
  string :description, description: "Description of the step", required: true
  number :time, description: "Optional time duration for the step in seconds"
end
