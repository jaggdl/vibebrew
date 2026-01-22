module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where(published: true).select(&:generated?) }
    scope :unpublished, -> { where(published: false) }
  end

  def publish!
    update!(published: true)
  end

  def unpublish!
    update!(published: false)
  end
end
