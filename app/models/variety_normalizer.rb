module VarietyNormalizer
  # Maps raw extracted strings (de-accented, lowercased, descriptors removed) to
  # canonical English variety names and an optional percentage.
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

  # Raw values that are origins or processing methods rather than varieties.
  IGNORED = %w[colombia garnica pluma supernatural].freeze
  IGNORED_PHRASES = [ "costa rica" ].freeze

  def self.canonicalize(raw)
    text = raw.to_s.strip

    percentage = percentage_of(text)
    base = strip_percentage_and_descriptors(text)
    key = key_for(base)

    return nil if key.blank? || ignored_key?(key)

    name, override_percentage = OVERRIDES[key]
    [ name || titleize(base), percentage || override_percentage ]
  end

  def self.key_for(name)
    I18n.transliterate(name.to_s)
       .downcase
       .gsub(/[^a-z0-9]+/, " ")
       .strip
       .gsub(/\s+/, " ")
  end

  def self.ignored_key?(key)
    IGNORED.include?(key) || IGNORED_PHRASES.include?(key)
  end

  def self.percentage_of(text)
    match = text.match(/(\d{1,3})\s*%/)
    match ? match[1].to_i.clamp(1, 100) : nil
  end

  def self.strip_percentage_and_descriptors(text)
    text.to_s.gsub(/\(\s*\d{1,3}\s*%\)/, " ").gsub(/\b\d{1,3}\s*%/, " ").strip
  end

  def self.titleize(name)
    name.split.map { |word| word.match?(/\A[a-z]+\z/) ? word.capitalize : word }.join(" ")
  end
end
