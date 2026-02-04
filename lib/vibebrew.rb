module Vibebrew
  class << self
    def saas?
      return @saas if defined?(@saas) && !@saas.nil?
      @saas = saas_enabled?
    end

    def self_hosted?
      !saas?
    end

    def reload_mode!
      @saas = nil
    end

    def saas_enabled?
      return true if ENV["SAAS"] && !ENV["SAAS"].empty?
      return true if File.exist?(File.expand_path("../tmp/saas.txt", __dir__))
      false
    end

    def configure_bundle
      if saas?
        ENV["BUNDLE_GEMFILE"] = "Gemfile.saas"
      end
    end
  end
end
