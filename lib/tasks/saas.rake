namespace :saas do
  desc "Enable SaaS mode"
  task enable: :environment do
    FileUtils.mkdir_p(Rails.root.join("tmp"))
    FileUtils.touch(Rails.root.join("tmp/saas.txt"))
    Vibebrew.reload_mode!
    puts "SaaS mode enabled. Run 'bin/rails db:migrate' to apply SaaS migrations."
    puts "Current mode: #{Vibebrew.saas? ? 'SaaS' : 'Self-hosted'}"
  end

  desc "Disable SaaS mode"
  task disable: :environment do
    saas_file = Rails.root.join("tmp/saas.txt")
    FileUtils.rm_f(saas_file)
    Vibebrew.reload_mode!
    puts "SaaS mode disabled."
    puts "Current mode: #{Vibebrew.saas? ? 'SaaS' : 'Self-hosted'}"
  end

  desc "Show current mode status"
  task status: :environment do
    mode = Vibebrew.saas? ? "SaaS" : "Self-hosted"
    source = determine_mode_source
    puts "Current mode: #{mode}"
    puts "Mode source: #{source}"
  end

  def determine_mode_source
    if ENV["SAAS"] && !ENV["SAAS"].empty?
      "SAAS environment variable"
    elsif File.exist?(Rails.root.join("tmp/saas.txt"))
      "tmp/saas.txt file"
    else
      "default"
    end
  end
end
