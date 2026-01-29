class SitemapsController < ApplicationController
  allow_unauthenticated_access

  def show
    sitemap_path = Rails.root.join("storage", "sitemap.xml")

    if File.exist?(sitemap_path)
      render xml: File.read(sitemap_path)
    else
      head :not_found
    end
  end
end
