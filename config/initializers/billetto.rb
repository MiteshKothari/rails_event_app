Rails.application.config.to_prepare do
  access_key_id = Rails.application.credentials.dig(:billetto, :access_key_id) || ENV["BILLETTO_ACCESS_KEY_ID"]
  access_key_secret = Rails.application.credentials.dig(:billetto, :access_key_secret) || ENV["BILLETTO_ACCESS_KEY_SECRET"]

  Rails.configuration.billetto_client = Billetto::Client.new(api_key: "#{access_key_id}:#{access_key_secret}")
end
