module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where(published: true) }
    scope :unpublished, -> { where(published: false) }
  end

  def publish!
    update!(published: true)
  end

  def unpublish!
    update!(published: false)
  end

  def toggle_publish
    if published?
      unpublish!
    else
      publish!
    end
  end
end
