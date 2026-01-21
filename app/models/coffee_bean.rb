class CoffeeBean < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :recipes, dependent: :destroy

  validate :has_at_least_one_image, on: :create

  def display_name
    brand.present? ? brand : "Coffee Bean ##{id}"
  end

  def v60_recipes
    recipes.v60
  end

  def aeropress_recipes
    recipes.aeropress
  end

  private

  def has_at_least_one_image
    errors.add(:images, "must have at least one image attached") unless images.attached?
  end
end
