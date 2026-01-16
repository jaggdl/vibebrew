class CoffeeBean < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :aeropress_recipes, dependent: :destroy
  has_many :v60_recipes, dependent: :destroy
end
