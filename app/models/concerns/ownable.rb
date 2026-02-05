module Ownable
  extend ActiveSupport::Concern

  def owned_by?(user)
    self.user.id == user&.id
  end

  def owned_by_current_user?
    owned_by?(Current.user)
  end
end
