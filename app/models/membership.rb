class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validates :user_id, uniqueness: { scope: :team_id }
  validates :role, presence: true

  enum :role, { member: "member", admin: "admin", owner: "owner" }

  def self.roles_for_select
    roles.keys.without("admin").map { |r| [ r.capitalize, r ] }
  end

  def role_icon
    case role
    when "owner" then "crown"
    when "admin" then "shield"
    else "user"
    end
  end

  def role_display_name
    role.capitalize
  end

  def can_manage_users?
    admin? || owner?
  end

  def can_manage_settings?
    admin?
  end

  def can_manage_billing?
    admin?
  end

  def editable?
    Current.user != user && Current.can_manage_users? && !admin?
  end
end
