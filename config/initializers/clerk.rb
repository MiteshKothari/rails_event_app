Rails.application.config.to_prepare do
  Rails.configuration.clerk_client = Clerk::Client.new
end
