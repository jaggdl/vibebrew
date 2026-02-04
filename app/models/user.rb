class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :coffee_beans, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :recipe_comments, dependent: :destroy

  has_many :favorite_coffee_beans, dependent: :destroy
  has_many :favorites, through: :favorite_coffee_beans, source: :coffee_bean

  has_many :coffee_bean_rotations, dependent: :destroy
  has_many :rotations, through: :coffee_bean_rotations, source: :coffee_bean

  has_many :favorite_recipes, dependent: :destroy
  has_many :favorite_recipes_list, through: :favorite_recipes, source: :recipe

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  def membership_in(team)
    memberships.find_by(team: team)
  end

  def admin_of?(team)
    membership_in(team)&.admin?
  end

  has_one_attached :avatar

  validates :name, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
