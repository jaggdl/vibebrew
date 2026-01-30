module BrewingMethods
  class Chemex < BrewingMethod
    def self.label
      "Chemex"
    end

    def self.icon
      "flask-conical"
    end

    private

    def method_specific_instructions
      <<~INSTRUCTIONS
        Chemex-specific considerations:
        - Use Chemex-specific bonded filters (thicker than standard pour-over filters)
        - Use medium-coarse grind (slightly coarser than V60)
        - Typical ratio is 1:15 to 1:17 coffee to water
        - Include a bloom phase (2x coffee weight in water for 30-45 seconds)
        - Pour in slow, steady circles from the center outward
        - Total brew time should typically be 3:30-4:30 minutes
        - The thick filter produces a clean, bright cup

      INSTRUCTIONS
    end
  end
end
