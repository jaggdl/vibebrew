class Comment < ApplicationRecord
  include Publishable

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :body, presence: true

  # Helper to get the owner of the commentable (for authorization)
  def commentable_owner
    commentable.respond_to?(:user) ? commentable.user : nil
  end

  def owned_by_current_user?
    commentable.respond_to?(:owned_by_current_user?) && commentable.owned_by_current_user?
  end
end
