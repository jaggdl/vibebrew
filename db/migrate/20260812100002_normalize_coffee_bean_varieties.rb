class NormalizeCoffeeBeanVarieties < ActiveRecord::Migration[8.0]
  # Historical, one-time backfill of the legacy free-text `coffee_beans.variety`
  # JSON column into the new `varieties` / `coffee_bean_varieties` tables.
  # Kept self-contained so fresh databases can be migrated without app code.

  OVERRIDES = {
    "arabica" => [ "Arabica", nil ],
    "100 arabica" => [ "Arabica", 100 ],
    "arabica europea" => [ "Arabica", nil ],
    "anacafe 14" => [ "Anacafe 14", nil ],
    "bourbon" => [ "Bourbon", nil ],
    "bourbon amarillo" => [ "Bourbon Amarillo", nil ],
    "catimor" => [ "Catimor", nil ],
    "catuai" => [ "Catuai", nil ],
    "caturra" => [ "Caturra", nil ],
    "gesha" => [ "Gesha", nil ],
    "grafted ruiru ii" => [ "Ruiru II", nil ],
    "maragogype" => [ "Maragogype", nil ],
    "marsellesa" => [ "Marsellesa", nil ],
    "pacamara" => [ "Pacamara", nil ],
    "ruiru ii" => [ "Ruiru II", nil ],
    "sl28" => [ "SL28", nil ],
    "sl34" => [ "SL34", nil ],
    "typica" => [ "Typica", nil ]
  }.freeze
  IGNORED = [ "colombia", "garnica", "pluma", "supernatural", "costa rica" ].freeze

  def up
    CoffeeBean.find_each do |bean|
      Array(bean["variety"]).each do |raw|
        canonical = canonicalize(raw)
        next unless canonical

        name, percentage = canonical
        variety = Variety.find_or_create_by!(name: name)

        unit = bean.coffee_bean_varieties.find_or_initialize_by(variety: variety)
        unit.percentage ||= percentage
        unit.save!
      end
    end
  end

  def down
    CoffeeBeanVariety.delete_all
    Variety.delete_all
  end

  private

  def canonicalize(raw)
    text = raw.to_s.strip
    return nil if text.blank?

    percentage_match = text.match(/(\d{1,3})\s*%/)
    percentage = percentage_match && percentage_match[1].to_i.clamp(1, 100)
    base = text.gsub(/\(\s*\d{1,3}\s*%\)/, " ").gsub(/\b\d{1,3}\s*%/, " ").strip
    key = key_for(base)

    return nil if IGNORED.include?(key)

    name, override_percentage = OVERRIDES[key]
    [ name || titleize(base), percentage || override_percentage ]
  end

  def key_for(name)
    I18n.transliterate(name.to_s).downcase.gsub(/[^a-z0-9]+/, " ").strip.gsub(/\s+/, " ")
  end

  def titleize(name)
    name.split.map { |word| word.match?(/\A[a-z]+\z/) ? word.capitalize : word }.join(" ")
  end
end
