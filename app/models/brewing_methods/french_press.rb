module BrewingMethods
  class FrenchPress < BrewingMethod
    def self.label
      "French Press"
    end

    def self.icon
      "beer"
    end

    private

    def method_specific_instructions
      <<~INSTRUCTIONS
        French Press-specific considerations:
        - Use coarse grind to prevent sediment passing through the mesh filter
        - Typical ratio is 1:15 coffee to water
        - Steep time is usually 4 minutes
        - Include instructions for proper plunging technique (slow and steady)
        - Water temperature should be just off boil (around 93-96°C / 200-205°F)

      INSTRUCTIONS
    end
  end
end
