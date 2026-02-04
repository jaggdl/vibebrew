class Team < ApplicationRecord
  include MultiTenantable
  include Sluggable

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :coffee_beans, dependent: :nullify
  has_many :recipes, dependent: :nullify

  validates :name, presence: true

  before_create :generate_invite_code

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

  def regenerate_invite_code!
    update!(invite_code: SecureRandom.hex(16))
  end

  def invite_url
    Rails.application.routes.url_helpers.join_team_url(slug: slug, invite_code: invite_code, host: ENV["BASE_URL"])
  end

  private

  def slug_source
    name
  end

  def default_slug_base
    "team"
  end

  def generate_invite_code
    self.invite_code ||= SecureRandom.hex(16)
  end
end
