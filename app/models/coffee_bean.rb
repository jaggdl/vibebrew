class CoffeeBean < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :aeropress_recipes, dependent: :destroy
end
