class Recipe < ApplicationRecord
  include Publishable
  include Sluggable

  belongs_to :coffee_bean
  belongs_to :source_recipe, class_name: "Recipe", optional: true
  has_many :iterations, class_name: "Recipe", foreign_key: :source_recipe_id, dependent: :nullify
  has_many :comments, class_name: "RecipeComment", dependent: :destroy

  has_many :favorite_recipes, dependent: :destroy
  has_many :favorited_by_users, through: :favorite_recipes, source: :user

  validates :recipe_type, presence: true, inclusion: { in: BrewingMethods.all }
  validates :grind_size, inclusion: { in: [ "extra fine", "fine", "medium", "coarse", "extra coarse" ] }, allow_blank: true
  validates :coffee_weight, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :water_weight, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :water_temperature, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  delegate :user, :belongs_to_current_user?, to: :coffee_bean
  delegate :label, :icon, to: :brewing_method, prefix: :brew_method

  scope :favorited, -> { joins(:favorite_recipes).distinct }

  BrewingMethods.all.each do |method_type|
    scope method_type, -> { where(recipe_type: method_type) }

    define_method("#{method_type}?") do
      recipe_type == method_type
    end
  end

  def brewing_method
    BrewingMethods.for(recipe_type)
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

  def seo_metadata
    SeoMetadata::Recipe.new(self)
  end

  def favorited_by_current_user
    Current.user&.favorite_recipes_list&.include?(self)
  end

  private

  def slug_source
    name
  end

  def default_slug_base
    "#{recipe_type}-recipe"
  end
end
