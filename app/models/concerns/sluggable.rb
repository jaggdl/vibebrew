module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, on: :create
    validates :slug, presence: true, uniqueness: true
  end

  def regenerate_slug!
    return unless slug_source.present?

    new_slug = "#{parameterize(slug_source)}-#{SecureRandom.hex(2)}"
    update!(slug: new_slug)
  end

  private

  def generate_slug
    return if slug.present?

    base = slug_source.presence || default_slug_base
    self.slug = "#{parameterize(base)}-#{SecureRandom.hex(2)}"
  end

  def parameterize(text)
    text.to_s.downcase.gsub(/[^a-z0-9\s-]/, "").gsub(/[\s-]+/, "-").gsub(/^-|-$/, "")
  end

  def slug_source
    raise NotImplementedError, "Subclasses must implement #slug_source"
  end

  def default_slug_base
    raise NotImplementedError, "Subclasses must implement #default_slug_base"
  end
end
