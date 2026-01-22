class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :coffee_beans, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :recipe_comments, dependent: :destroy

  has_one_attached :avatar

  validates :name, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
