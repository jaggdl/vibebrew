class CoffeeBean < ApplicationRecord
  include Publishable
  include Sluggable

  belongs_to :user
  has_many_attached :images
  has_many :recipes, dependent: :destroy

  validate :has_at_least_one_image, on: :create

  def display_name
    brand.present? ? brand : "Coffee Bean ##{id}"
  end

  def generated?
    brand.present?
  end

  def v60_recipes
    recipes.v60
  end

  def aeropress_recipes
    recipes.aeropress
  end

  def published_recipes
    recipes.published
  end

  def seo_metadata
    SeoMetadata::CoffeeBean.new(self)
  end

  private

  def has_at_least_one_image
    errors.add(:images, "must have at least one image attached") unless images.attached?
  end

  def slug_source
    parts = [ brand, variety&.first, origin || producer ].compact
    parts.join(" ") if parts.any?
  end

  def default_slug_base
    "coffee-bean"
  end
end
