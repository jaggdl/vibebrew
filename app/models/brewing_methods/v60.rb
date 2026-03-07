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
        - Include a bloom phase
        - Consider pour rate and technique for each stage

      INSTRUCTIONS
    end
  end
end
