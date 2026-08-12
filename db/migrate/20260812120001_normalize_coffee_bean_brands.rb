class NormalizeCoffeeBeanBrands < ActiveRecord::Migration[8.0]
  # Historical, one-time backfill of the legacy free-text `coffee_beans.brand`
  # string column into the new `brands` table. Kept self-contained so fresh
  # databases can be migrated without app code.

  ALIASES = {
    "caulca" => "CAULCA",
    "cafe estelar" => "Café Estelar",
    "cafeologia" => "Cafeología",
    "colonna" => "Colonna",
    "formative" => "FORMATIVE",
    "fruta" => "Fruta",
    "fruta disfruta" => "Fruta",
    "gran tostador" => "Gran Tostador",
    "gypsy coffee roasters" => "Gypsy Coffee Roasters",
    "huupa" => "HUUPA",
    "hola coffee" => "Hola Coffee",
    "lune" => "LUNE",
    "makeworth coffee" => "Makeworth Coffee",
    "polvora" => "PÓLVORA",
    "spring valley coffee" => "Spring Valley Coffee",
    "starbucks" => "Starbucks",
    "terres de cafe" => "Terres de Café",
    "shiroba" => "[SHIROBA]",
    "the coffee" => "The Coffee."
  }.freeze

  def up
    CoffeeBean.find_each do |bean|
      raw = bean["brand"].to_s.strip
      next if raw.blank?

      name = ALIASES.fetch(key_for(raw), raw)
      brand = Brand.find_or_create_by!(name: name)
      bean.update_column(:brand_id, brand.id)
    end
  end

  def down
    CoffeeBean.update_all(brand_id: nil)
    Brand.delete_all
  end

  private

  def key_for(text)
    I18n.transliterate(text.to_s).downcase.gsub(/[^a-z0-9]+/, " ").strip.gsub(/\s+/, " ")
  end
end
