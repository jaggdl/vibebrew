module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :can_manage_users?, :can_manage_settings?, :current_role
  end

  private

  def require_admin
    return if can_manage_users?
    redirect_to root_path, alert: "You don't have permission to access this page"
  end

  def require_owner
    return if can_manage_settings?
    redirect_to root_path, alert: "You don't have permission to access this page"
  end

  def can_manage_users?
    return false unless Current.user

    Current.user.can_manage_users?
  end

  def can_manage_settings?
    return false unless Current.user

    Current.user.can_manage_settings?
  end

  def current_role
    return nil unless authenticated?

    Current.user.role
  end
end
