class Sitemap::GenerateJob < ApplicationJob
  queue_as :default

  def perform
    Sitemap.generate_now
  end
end
