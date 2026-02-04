Gem::Specification.new do |spec|
  spec.name = "vibebrew-saas"
  spec.version = VibebrewSaas::VERSION
  spec.authors = [ "VibeBrew Team" ]
  spec.email = [ "team@vibebrew.com" ]

  spec.summary = "SaaS functionality for VibeBrew"
  spec.description = "Multi-tenancy, Stripe billing, and plan-based limits for VibeBrew"
  spec.homepage = "https://vibebrew.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "stripe"
end
