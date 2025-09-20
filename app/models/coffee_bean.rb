class CoffeeBean < ApplicationRecord
  has_many_attached :images
  has_many :aeropress_recipes, dependent: :destroy
end
