module RecipeAttributes
  extend ActiveSupport::Concern

  included do
    belongs_to :coffee_bean

    validates :grind_size, inclusion: { in: [ "extra fine", "fine", "medium", "coarse", "extra coarse" ] }, allow_blank: true
    validates :coffee_weight, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
    validates :water_weight, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
    validates :water_temperature, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  end

  def generated?
    name.present?
  end

  def display_name
    name.present? ? name : "Recipe ##{id}"
  end
end
