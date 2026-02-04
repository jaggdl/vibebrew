class Current < ActiveSupport::CurrentAttributes
  attribute :session, :team, :membership
  delegate :user, to: :session, allow_nil: true

  def can_manage_users?
    membership&.can_manage_users?
  end

  def can_manage_settings?
    membership&.can_manage_settings?
  end

  def can_manage_billing?
    membership&.can_manage_billing?
  end
end
