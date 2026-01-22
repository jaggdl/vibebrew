class SeoMetadata::Recipe < SeoMetadata
  def title
    "#{record.display_name} | #{record.brew_method_name} Recipe | Vibe Coffee"
  end

  def description
    parts = []
    parts << "A #{record.brew_method_name} recipe for #{record.coffee_bean.display_name}"
    parts << "#{record.coffee_weight}g coffee" if record.coffee_weight.present?
    parts << "#{record.water_weight}g water" if record.water_weight.present?
    parts << "#{record.grind_size} grind" if record.grind_size.present?
    parts << record.description.truncate(80) if record.description.present?
    parts.join(". ").truncate(160)
  end

  def og_title
    "#{record.display_name} - #{record.brew_method_name}"
  end

  def og_type
    "article"
  end

  def og_image
    record.coffee_bean.images.first if record.coffee_bean.images.attached?
  end
end
