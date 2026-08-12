class CoffeeBeanVariety < ApplicationRecord
  belongs_to :coffee_bean
  belongs_to :variety

  validates :percentage, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }, allow_nil: true

  def display_name
    percentage ? "#{variety.name} (#{percentage}%)" : variety.name
  end
end
