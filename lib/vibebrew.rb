module VibeBrew
  def self.saas?
    return @saas if defined?(@saas) && !@saas.nil?
    @saas = saas_enabled?
  end

  def self.self_hosted?
    !saas?
  end

  def self.reload_mode!
    @saas = nil
  end

  def self.saas_enabled?
    return true if ENV["SAAS"] && !ENV["SAAS"].empty?
    return true if defined?(Rails) && Rails.root && File.exist?(Rails.root.join("tmp/saas.txt"))
    false
  end
end
