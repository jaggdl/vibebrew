class GenerateSitemapJob < ApplicationJob
  queue_as :default

  def perform
    sitemap_path = Rails.root.join("storage", "sitemap.xml")
    File.write(sitemap_path, generate_sitemap_xml)
    Rails.logger.info "Sitemap generated at #{sitemap_path}"
  end

  private

  def generate_sitemap_xml
    host = Rails.application.routes.default_url_options[:host] || "https://vibebrew.coffee"

    xml = Builder::XmlMarkup.new(indent: 2)
    xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

    xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
      CoffeeBean.published.find_each do |bean|
        xml.url do
          xml.loc "#{host}/beans/#{bean.slug}"
          xml.lastmod bean.updated_at.strftime("%Y-%m-%d")
          xml.changefreq "weekly"
          xml.priority "0.8"
        end
      end

      Recipe.published.find_each do |recipe|
        xml.url do
          xml.loc "#{host}/brews/#{recipe.slug}"
          xml.lastmod recipe.updated_at.strftime("%Y-%m-%d")
          xml.changefreq "weekly"
          xml.priority "0.6"
        end
      end
    end
  end
end
