class NormalizeCoffeeBeanProcessingMethods < ActiveRecord::Migration[8.0]
  # Historical, one-time backfill of the legacy free-text `coffee_beans.process`
  # JSON column into the new `processing_methods` / `coffee_bean_processing_methods`
  # tables. Kept self-contained so fresh databases can be migrated without app code.

  ALIASES = {
    "anaerobic" => "Anaerobic",
    "anaerobic anaerobico" => "Anaerobic",
    "anaerobic natural" => "Anaerobic",
    "black honey" => "Honey",
    "fermented" => "Fermented",
    "fully washed" => "Washed",
    "hidronatural" => "Hydro-natural",
    "lavado" => "Washed",
    "lavado washed" => "Washed",
    "natural" => "Natural",
    "semi washed" => "Semi-washed",
    "sun dried" => "Natural",
    "washed" => "Washed",
    "washed lavado" => "Washed"
  }.freeze
  IGNORED = [ "e50", "supernatural" ].freeze

  def up
    CoffeeBean.find_each do |bean|
      Array(bean["process"]).each do |raw|
        name = canonicalize(raw)
        next if name.blank?

        processing_method = ProcessingMethod.find_or_create_by!(name: name)

        unit = bean.coffee_bean_processing_methods.find_or_create_by!(processing_method: processing_method)
      end
    end
  end

  def down
    CoffeeBeanProcessingMethod.delete_all
    ProcessingMethod.delete_all
  end

  private

  def canonicalize(raw)
    text = raw.to_s.strip
    return nil if text.blank?

    key = key_for(text)
    return nil if IGNORED.include?(key)

    ALIASES[key] || titleize(key)
  end

  def key_for(text)
    stripped = text.gsub(/\(\s*\d{1,3}\s*%\)/, " ").gsub(/\b\d{1,3}\s*%/, " ")
    I18n.transliterate(stripped).downcase.gsub(/[^a-z0-9]+/, " ").strip.gsub(/\s+/, " ")
  end

  def titleize(name)
    name.split.map { |word| word.match?(/\A[a-z]+\z/) ? word.capitalize : word }.join(" ")
  end
end
