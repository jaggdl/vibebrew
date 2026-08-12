class NormalizeCoffeeBeanVarieties < ActiveRecord::Migration[8.0]
  def up
    CoffeeBean.find_each do |bean|
      Array(bean.variety).each do |raw|
        canonical = VarietyNormalizer.canonicalize(raw)
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
end
