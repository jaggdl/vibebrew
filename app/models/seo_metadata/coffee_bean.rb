class SeoMetadata::CoffeeBean < SeoMetadata
  def title
    "#{record.display_name} | Vibe Coffee"
  end

  def description
    parts = []
    parts << "from #{record.origin}" if record.origin.present?
    parts << "by #{record.producer}" if record.producer.present?
    parts << record.variety.to_sentence if record.variety.present? && record.variety.any?
    parts << "#{record.process.to_sentence} process" if record.process.present? && record.process.any?
    parts << "Tasting notes: #{record.tasting_notes.to_sentence}" if record.tasting_notes.present? && record.tasting_notes.any?

    base = record.display_name
    base += " - #{parts.join('. ')}" if parts.any?
    base.truncate(160)
  end

  def og_type
    "product"
  end

  def og_image
    return nil unless record.images.attached?

    variant = record.images.first.variant(resize_to_fill: [ 1200, 630 ])
    Rails.application.routes.url_helpers.rails_representation_url(
      variant,
      host: ENV.fetch("BASE_URL", "http://localhost:3000")
    )
  end
end
