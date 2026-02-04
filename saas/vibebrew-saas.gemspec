require_relative "lib/vibebrew/saas/version"

Gem::Specification.new do |spec|
  spec.name = "vibebrew-saas"
  spec.version = Vibebrew::Saas::VERSION
  spec.authors = [ "Vibebrew Team" ]
  spec.email = [ "yo@jaggdl.com" ]

  spec.summary = "SaaS functionality for Vibebrew"
  spec.description = "Multi-tenancy, Stripe billing, and plan-based limits for Vibebrew"
  spec.homepage = "https://vibebrew.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "stripe"
end
