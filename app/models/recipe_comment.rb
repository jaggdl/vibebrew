class RecipeComment < ApplicationRecord
  include Publishable

  belongs_to :recipe
  belongs_to :user

  validates :body, presence: true
end
