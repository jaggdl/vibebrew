class SeoMetadata::Recipe < SeoMetadata
  def title
    "#{record.display_name} | #{record.brew_method_label} Recipe | VibeBrew"
  end

  def description
    parts = []
    parts << "A #{record.brew_method_label} recipe for #{record.coffee_bean.display_name}"
    parts << "#{record.coffee_weight}g coffee" if record.coffee_weight.present?
    parts << "#{record.water_weight}g water" if record.water_weight.present?
    parts << "#{record.grind_size} grind" if record.grind_size.present?
    parts << record.description.truncate(80) if record.description.present?
    parts.join(". ").truncate(160)
  end

  def og_title
    "#{record.display_name} - #{record.brew_method_label}"
  end

  def og_type
    "article"
  end

  def og_image
    return nil unless record.coffee_bean.images.attached?

    variant = record.coffee_bean.images.first.variant(resize_to_fill: [ 1200, 630 ])
    Rails.application.routes.url_helpers.rails_representation_url(
      variant,
      host: ENV.fetch("BASE_URL", "http://localhost:3000")
    )
  end
end
