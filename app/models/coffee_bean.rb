class CoffeeBean < ApplicationRecord
  include Ownable, Publishable, Sluggable, VectorSearch, InfoExtraction

  belongs_to :user
  belongs_to :team, optional: true
  belongs_to :brand, optional: true
  has_many_attached :images
  has_many :recipes, dependent: :destroy

  has_many :favorite_coffee_beans, dependent: :destroy
  has_many :favorited_by_users, through: :favorite_coffee_beans, source: :user

  has_many :coffee_bean_rotations, dependent: :destroy
  has_many :in_rotation_for_users, through: :coffee_bean_rotations, source: :user
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :coffee_bean_varieties, dependent: :destroy
  has_many :varieties, through: :coffee_bean_varieties

  has_many :coffee_bean_processing_methods, dependent: :destroy
  has_many :processing_methods, through: :coffee_bean_processing_methods

  attr_accessor :variety_selection
  attr_accessor :processing_method_selection

  validate :has_at_least_one_image, on: :create

  def display_name
    parts = []

    parts << "#{brand.name}:" if brand.present?
    parts << display_variety if varieties.any?
    parts << "(#{display_process})" if processing_methods.any?
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

  def other_beans_from_brand(limit: 4)
    return self.class.none if brand.blank?

    self.class.where(brand: brand, user: user).where.not(id: id).limit(limit)
  end

  def all_recipes_for(user)
    favorite_ids = user.favorite_recipes_list.pluck(:id)
    recipes.sort_by { |r| [ favorite_ids.include?(r.id) ? 0 : 1, -r.created_at.to_i ] }
  end

  def favorite_recipes
    recipes.favorited
  end

  def seo_metadata
    SeoMetadata::CoffeeBean.new(self)
  end

  def display_variety
    coffee_bean_varieties.includes(:variety).map(&:display_name).join(", ")
  end

  def variety_names
    varieties.order(:name).pluck(:name).join(", ")
  end

  def variety_selection=(selection)
    coffee_bean_varieties.destroy_all

    Array(selection).each do |_idx, row|
      next unless row[:enabled] == "1"

      percentage = row[:percentage].presence&.to_i
      coffee_bean_varieties.build(variety_id: row[:variety_id], percentage: percentage)
    end
  end

  def display_process
    processing_method_names
  end

  def processing_method_names
    processing_methods.order(:name).pluck(:name).join(", ")
  end

  def processing_method_selection=(selection)
    coffee_bean_processing_methods.destroy_all

    Array(selection).each do |_idx, row|
      next unless row[:enabled] == "1"

      coffee_bean_processing_methods.build(processing_method_id: row[:processing_method_id])
    end
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
end
