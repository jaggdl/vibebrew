module BrewingMethods
  class V60 < BrewingMethod
    def self.label
      "Hario V60"
    end

    def self.icon
      "cone"
    end

    private

    def method_specific_instructions
      <<~INSTRUCTIONS
        V60-specific considerations:
        - Include a bloom phase (typically 2x coffee weight in water for 30-45 seconds)
        - Specify pour stages (e.g., center pour, spiral pour, pulse pours)
        - Consider pour rate and technique for each stage
        - Total brew time should typically be 2:30-3:30 minutes

      INSTRUCTIONS
    end
  end
end
