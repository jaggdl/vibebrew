class Team < ApplicationRecord
  include MultiTenantable

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :coffee_beans, dependent: :nullify
  has_many :recipes, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  def owner
    memberships.find_by(role: :owner)&.user
  end

  def add_member(user, role: :member)
    memberships.create!(user: user, role: role)
  end

  def remove_member(user)
    memberships.find_by(user: user)&.destroy
  end

  def member?(user)
    memberships.exists?(user: user)
  end

  def role_for(user)
    memberships.find_by(user: user)&.role
  end

  private

  def generate_slug
    return if slug.present?

    base_slug = name.to_s.parameterize
    self.slug = base_slug

    counter = 1
    while self.class.exists?(slug: slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
