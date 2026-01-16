class GenerateAeropressRecipeJob < ApplicationJob
  queue_as :default

  def perform(aeropress_recipe_id)
    aeropress_recipe = AeropressRecipe.find(aeropress_recipe_id)
    coffee_bean = aeropress_recipe.coffee_bean

    # Create a chat record for processing
    chat_record = Chat.create!(model: "gpt-4.1-mini")

    # Build prompt for recipe generation
    prompt = build_recipe_prompt(coffee_bean, aeropress_recipe)

    # Get image blobs for RubyLLM if coffee bean has images
    image_blobs = coffee_bean.images.attached? ? coffee_bean.images.map(&:blob) : []

    # Generate structured recipe using the schema
    response = chat_record.with_schema(AeropressRecipeSchema).ask(prompt, with: image_blobs)

    # Update the aeropress recipe with generated information
    aeropress_recipe.update!(response.content)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "AeropressRecipe with id #{aeropress_recipe_id} not found"
  rescue StandardError => e
    Rails.logger.error "Failed to generate aeropress recipe for #{aeropress_recipe_id}: #{e.message}"
    raise
  end

  private

  def build_recipe_prompt(coffee_bean, aeropress_recipe)
    coffee_info = build_coffee_info_section(coffee_bean)
    user_prompt = aeropress_recipe.prompt

    <<~PROMPT
      I need you to create a detailed AeroPress brewing recipe for the following coffee:

      #{coffee_info}

      User's brewing preferences/requirements:
      #{user_prompt}

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
