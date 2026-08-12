class CoffeeBeanProcessingMethod < ApplicationRecord
  belongs_to :coffee_bean
  belongs_to :processing_method
end
