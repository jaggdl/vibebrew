class CoffeeBeanVarietySchema < RubyLLM::Schema
  string :name, description: "The type of coffee bean in English (e.g., Arabica, Typica, Bourbon)"
  integer :percentage, description: "The percentage this variety makes up of the blend. Only set if explicitly stated on the package, otherwise omit.", minimum: 1, maximum: 100
end
