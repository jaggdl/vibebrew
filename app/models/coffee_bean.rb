class CoffeeBean < ApplicationRecord
  include Publishable
  include Sluggable

  belongs_to :user
  has_many_attached :images
  has_many :recipes, dependent: :destroy

  validate :has_at_least_one_image, on: :create

  def display_name
    parts = []

    parts << "#{brand}:" if brand.present?
    parts << display_variety if variety.any?
    parts << "(#{display_process})" if process.any?
    parts << "- #{origin || producer}" if origin.present? || producer.present?

    parts.any? ? parts.join(" ") : "Coffee Bean ##{id}"
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

  def display_variety
    oxford_comma(variety || [])
  end

  def display_process
    oxford_comma(process || [])
  end

  private

  def has_at_least_one_image
    errors.add(:images, "must have at least one image attached") unless images.attached?
  end

  def slug_source
    display_name
  end

  def default_slug_base
    "coffee-bean"
  end

  def oxford_comma(list)
    return "" if list.blank?

    case list.size
    when 1 then list.first
    when 2 then "#{list.first} and #{list.second}"
    else
      "#{list[0..-2].join(', ')} and #{list.last}"
    end
  end
end
