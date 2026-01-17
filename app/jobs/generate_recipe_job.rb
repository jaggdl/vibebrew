class GenerateRecipeJob < ApplicationJob
  queue_as :default

  RECIPE_CONFIGS = {
    "AeropressRecipe" => {
      schema: AeropressRecipeSchema,
      prompt_builder: :build_aeropress_prompt
    },
    "V60Recipe" => {
      schema: V60RecipeSchema,
      prompt_builder: :build_v60_prompt
    }
  }.freeze

  def perform(recipe_class_name, recipe_id)
    recipe_class = recipe_class_name.constantize
    recipe = recipe_class.find(recipe_id)
    config = RECIPE_CONFIGS[recipe_class_name]

    raise ArgumentError, "Unknown recipe type: #{recipe_class_name}" unless config

    coffee_bean = recipe.coffee_bean
    prompt = send(config[:prompt_builder], coffee_bean, recipe)

    chat_record = Chat.create!(model: "gpt-5-mini")
    image_blobs = coffee_bean.images.attached? ? coffee_bean.images.map(&:blob) : []
    response = chat_record.with_schema(config[:schema]).ask(prompt, with: image_blobs)

    recipe.update!(response.content)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "#{recipe_class_name} with id #{recipe_id} not found"
  rescue StandardError => e
    Rails.logger.error "Failed to generate #{recipe_class_name} for #{recipe_id}: #{e.message}"
    raise
  end

  private

  def build_aeropress_prompt(coffee_bean, recipe)
    <<~PROMPT
      I need you to create a detailed AeroPress brewing recipe for the following coffee:

      #{build_coffee_info_section(coffee_bean)}

      User's brewing preferences/requirements:
      #{recipe.prompt}

      Please create a comprehensive AeroPress recipe that includes:
      - A descriptive name for the recipe
      - Detailed description explaining the approach and expected flavor profile
      - Whether to use inverted method (true/false)
      - Appropriate grind size (extra fine, fine, medium, coarse, extra coarse)
      - Coffee weight in grams
      - Water weight in grams
      - Water temperature in Celsius
      - Step-by-step brewing instructions with timing

      Consider the coffee's characteristics (origin, process, tasting notes) and the user's preferences to optimize the recipe.
      Make the recipe practical and achievable for home brewing.
      Each step should include a clear description and time duration where applicable (in seconds). If the step doesn't need to count the time (e.g. setting up the coffee beans), don't add it
    PROMPT
  end

  def build_v60_prompt(coffee_bean, recipe)
    <<~PROMPT
      I need you to create a detailed Hario V60 pour-over brewing recipe for the following coffee:

      #{build_coffee_info_section(coffee_bean)}

      User's brewing preferences/requirements:
      #{recipe.prompt}

      Please create a comprehensive V60 recipe that includes:
      - A descriptive name for the recipe
      - Detailed description explaining the approach and expected flavor profile
      - Appropriate grind size (extra fine, fine, medium, coarse, extra coarse)
      - Coffee weight in grams
      - Water weight in grams
      - Water temperature in Celsius
      - Step-by-step brewing instructions with timing

      V60-specific considerations:
      - Include a bloom phase (typically 2x coffee weight in water for 30-45 seconds)
      - Specify pour stages (e.g., center pour, spiral pour, pulse pours)
      - Consider pour rate and technique for each stage
      - Total brew time should typically be 2:30-3:30 minutes

      Consider the coffee's characteristics (origin, process, tasting notes) and the user's preferences to optimize the recipe.
      Make the recipe practical and achievable for home brewing.
      Each step should include a clear description and time duration where applicable (in seconds). If the step doesn't need to count the time (e.g. setting up the coffee beans), don't add it.
    PROMPT
  end

  def build_coffee_info_section(coffee_bean)
    info_parts = []

    info_parts << "Brand: #{coffee_bean.brand}" if coffee_bean.brand.present?
    info_parts << "Origin: #{coffee_bean.origin}" if coffee_bean.origin.present?
    info_parts << "Variety: #{coffee_bean.variety}" if coffee_bean.variety.present?
    info_parts << "Process: #{coffee_bean.process}" if coffee_bean.process.present?
    info_parts << "Tasting Notes: #{coffee_bean.tasting_notes}" if coffee_bean.tasting_notes.present?
    info_parts << "Producer: #{coffee_bean.producer}" if coffee_bean.producer.present?
    info_parts << "Additional Notes: #{coffee_bean.notes}" if coffee_bean.notes.present?

    if info_parts.empty?
      "Coffee Bean ##{coffee_bean.id} (limited information available)"
    else
      info_parts.join("\n")
    end
  end
end
