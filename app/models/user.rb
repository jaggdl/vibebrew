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

  has_one_attached :avatar

  # Roles for self-hosted mode (global permissions)
  enum :role, { member: "member", admin: "admin", owner: "owner" }

  validates :name, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Self-hosted role-based permissions
  def can_manage_users?
    admin? || owner?
  end

  def can_manage_settings?
    owner?
  end

  # Make first user the owner in self-hosted mode
  before_create :assign_owner_role_if_first_user

  private

  def assign_owner_role_if_first_user
    return if VibeBrew.saas?
    self.role = :owner if User.count.zero?
  end
end
