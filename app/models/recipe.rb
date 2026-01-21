class Recipe < ApplicationRecord
  include RecipeAttributes

  TYPES = %w[v60 aeropress].freeze

  has_many :comments, class_name: "RecipeComment", dependent: :destroy

  validates :recipe_type, presence: true, inclusion: { in: TYPES }

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
end
