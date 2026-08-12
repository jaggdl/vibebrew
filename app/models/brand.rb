class Brand < ApplicationRecord
  has_many :coffee_beans, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_validation :normalize_name

  def self.find_or_create_by_name(name)
    name = name.to_s.strip
    return nil if name.blank?

    key = normalize_key(name)
    existing = all.find { |b| normalize_key(b.name) == key }
    existing || create!(name: name)
  end

  def self.normalize_key(name)
    I18n.transliterate(name.to_s).downcase.gsub(/[^a-z0-9]+/, " ").strip.gsub(/\s+/, " ")
  end

  private

  def normalize_name
    self.name = name.to_s.strip
  end
end
