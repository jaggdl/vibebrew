class CoffeeBean::ExtractInfoJob < ApplicationJob
  queue_as :default

  def perform(coffee_bean)
    coffee_bean.extract_info_now
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "CoffeeBean with id #{coffee_bean.id} not found"
  end
end
