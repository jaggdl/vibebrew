class Recipe < ApplicationRecord
  include Publishable
  include Sluggable

  TYPES = %w[v60 aeropress].freeze

  belongs_to :coffee_bean
  belongs_to :source_recipe, class_name: "Recipe", optional: true
  has_many :iterations, class_name: "Recipe", foreign_key: :source_recipe_id, dependent: :nullify
  has_many :comments, class_name: "RecipeComment", dependent: :destroy

  validates :recipe_type, presence: true, inclusion: { in: TYPES }
  validates :grind_size, inclusion: { in: [ "extra fine", "fine", "medium", "coarse", "extra coarse" ] }, allow_blank: true
  validates :coffee_weight, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :water_weight, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :water_temperature, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  delegate :user, to: :coffee_bean

  scope :v60, -> { where(recipe_type: "v60") }
  scope :aeropress, -> { where(recipe_type: "aeropress") }

  def v60?
    recipe_type == "v60"
  end

  def aeropress?
    recipe_type == "aeropress"
  end

  def brew_method_name
    case recipe_type
    when "v60" then "V60"
    when "aeropress" then "AeroPress"
    else recipe_type.titleize
    end
  end

  def generated?
    name.present?
  end

  def display_name
    name.present? ? name : "Recipe ##{id}"
  end

  def formatted_temperature
    return nil if water_temperature.blank?

    fahrenheit = (water_temperature * 9.0 / 5.0 + 32).round
    "#{water_temperature}ºC or #{fahrenheit}ºF"
  end

  private

  def slug_source
    name
  end

  def default_slug_base
    "#{recipe_type}-recipe"
  end
end
