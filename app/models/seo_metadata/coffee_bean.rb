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
    record.images.first if record.images.attached?
  end
end
