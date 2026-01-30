module BrewingMethods
  class Espresso < BrewingMethod
    def self.label
      "Espresso"
    end

    def self.icon
      "gauge"
    end

    private

    def method_specific_instructions
      <<~INSTRUCTIONS
        Espresso-specific considerations:
        - Use fine grind (adjust based on shot timing)
        - Standard dose is 18-20g for a double shot
        - Target 25-30 second extraction time
        - Yield should be approximately 2x the dose (1:2 ratio)
        - Water temperature around 90-96°C (195-205°F)
        - Pressure should be around 9 bars
        - Include instructions for proper tamping (level and consistent pressure)

      INSTRUCTIONS
    end
  end
end
