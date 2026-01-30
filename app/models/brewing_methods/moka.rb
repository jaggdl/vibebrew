module BrewingMethods
  class Moka < BrewingMethod
    def self.label
      "Moka Pot"
    end

    def self.icon
      "flame"
    end

    private

    def method_specific_instructions
      <<~INSTRUCTIONS
        Moka Pot-specific considerations:
        - Use medium-fine grind (finer than drip, coarser than espresso)
        - Fill the bottom chamber with hot water up to the safety valve
        - Do not tamp the coffee, just level it off
        - Use low to medium heat to avoid burning
        - Remove from heat as soon as coffee starts gurgling/sputtering
        - Produces a strong, espresso-like concentrate

      INSTRUCTIONS
    end
  end
end
