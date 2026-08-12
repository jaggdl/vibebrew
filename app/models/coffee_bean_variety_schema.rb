class CoffeeBeanVarietySchema < RubyLLM::Schema
  string :name, description: "The type of coffee bean in English (e.g., Arabica, Typica, Bourbon)"
  integer :percentage, description: "The percentage this variety makes up of the blend (1-100), if stated on the package"
end
