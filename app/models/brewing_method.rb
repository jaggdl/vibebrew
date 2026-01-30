class BrewingMethod
  attr_reader :coffee_bean, :recipe

  def initialize(coffee_bean, recipe)
    @coffee_bean = coffee_bean
    @recipe = recipe
  end

  def self.label
    raise NotImplementedError, "Subclasses must implement .label"
  end

  def self.icon
    raise NotImplementedError, "Subclasses must implement .icon"
  end

  def schema
    RecipeSchema
  end

  def prompt
    base_prompt + iteration_or_new_section + instructions
  end

  private

  def brewing_method_name
    self.class.label
  end

  def method_specific_instructions
    ""
  end

  def base_prompt
    <<~PROMPT
      I need you to create a detailed #{brewing_method_name} brewing recipe for the following coffee:

      #{build_coffee_info_section}
    PROMPT
  end

  def iteration_or_new_section
    if recipe.source_recipe.present?
      <<~ITERATION

        This is an ITERATION of an existing recipe. Here is the original recipe to improve upon:
        #{build_source_recipe_section}

        User's feedback and iteration requirements:
        #{recipe.prompt}

        Please create an improved version of this recipe based on the user's feedback while maintaining the same general approach unless the feedback suggests otherwise.
      ITERATION
    else
      <<~NEW_RECIPE

        User's brewing preferences/requirements:
        #{recipe.prompt}
      NEW_RECIPE
    end
  end

  def instructions
    <<~INSTRUCTIONS

      Please create a comprehensive #{brewing_method_name} recipe that includes:
      - A descriptive name for the recipe
      - Detailed description explaining the approach and expected flavor profile
      - Appropriate grind size (extra fine, fine, medium, coarse, extra coarse)
      - Coffee weight in grams
      - Water weight in grams
      - Water temperature in Celsius
      - Step-by-step brewing instructions with timing

      #{method_specific_instructions}
      Consider the coffee's characteristics (origin, process, tasting notes) and the user's preferences to optimize the recipe.
      Make the recipe practical and achievable for home brewing.
      Each step should include a clear description and time duration where applicable (in seconds). If the step doesn't need to count the time (e.g. setting up the coffee beans), don't add it.
    INSTRUCTIONS
  end

  def build_coffee_info_section
    info_parts = []

    info_parts << "Brand: #{coffee_bean.brand}" if coffee_bean.brand.present?
    info_parts << "Origin: #{coffee_bean.origin}" if coffee_bean.origin.present?
    info_parts << "Variety: #{coffee_bean.variety.join(', ')}" if coffee_bean.variety.present?
    info_parts << "Process: #{coffee_bean.process.join(', ')}" if coffee_bean.process.present?
    info_parts << "Tasting Notes: #{coffee_bean.tasting_notes.join(', ')}" if coffee_bean.tasting_notes.present?
    info_parts << "Producer: #{coffee_bean.producer}" if coffee_bean.producer.present?
    info_parts << "Additional Notes: #{coffee_bean.notes}" if coffee_bean.notes.present?

    if info_parts.empty?
      "Coffee Bean ##{coffee_bean.id} (limited information available)"
    else
      info_parts.join("\n")
    end
  end

  def build_source_recipe_section
    source_recipe = recipe.source_recipe
    parts = []

    parts << "Recipe Name: #{source_recipe.name}" if source_recipe.name.present?
    parts << "Description: #{source_recipe.description}" if source_recipe.description.present?
    parts << "Grind Size: #{source_recipe.grind_size}" if source_recipe.grind_size.present?
    parts << "Coffee Weight: #{source_recipe.coffee_weight}g" if source_recipe.coffee_weight.present?
    parts << "Water Weight: #{source_recipe.water_weight}g" if source_recipe.water_weight.present?
    parts << "Water Temperature: #{source_recipe.water_temperature}°C" if source_recipe.water_temperature.present?

    if source_recipe.steps.present?
      steps_text = source_recipe.steps.map.with_index(1) do |step, i|
        time_info = step["time"].present? ? " (#{step['time']}s)" : ""
        "  #{i}. #{step['description']}#{time_info}"
      end.join("\n")
      parts << "Steps:\n#{steps_text}"
    end

    if source_recipe.comments.any?
      comments_text = source_recipe.comments.order(created_at: :asc).map do |comment|
        "  - #{comment.body}"
      end.join("\n")
      parts << "User Comments/Feedback:\n#{comments_text}"
    end

    parts.join("\n")
  end
end
