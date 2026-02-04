if defined?(Stripe) && defined?(VibeBrew) && VibeBrew.saas?
  Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key) || ENV["STRIPE_SECRET_KEY"]

  # Set API version for consistent behavior
  Stripe.api_version = "2023-10-16"

  # Enable automatic retries on network errors
  Stripe.max_network_retries = 2
end
