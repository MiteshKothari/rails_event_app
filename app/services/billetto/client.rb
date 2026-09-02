module Billetto
  class Client
    def initialize(api_key:, base_url: "https://billetto.dk/api/v3")
      @api_key = api_key
      @base_url = base_url
    end

    def list_public_events
      response = connection.get("public/events")
      handle_response(response)
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise UnexpectedResponse, "Billetto API request failed: #{e.message}"
    end

    private

    attr_reader :api_key, :base_url

    def connection
      @connection ||= Faraday.new(url: base_url) do |f|
        f.headers["Api-Keypair"] = api_key
        f.request :retry, max: 1, interval: 0.1
        f.response :json, content_type: /\bjson$/
        f.options.timeout = 60
        f.options.open_timeout = 30
        f.adapter Faraday.default_adapter
      end
    end

    def handle_response(response)
      case response.status
      when 200 then response.body.fetch("data", [])
      when 401 then raise Unauthorized, "Invalid Billetto API credentials"
      when 429 then raise RateLimited, "Billetto API rate limit exceeded"
      else raise UnexpectedResponse, "Unexpected Billetto API response: HTTP #{response.status}"
      end
    end
  end
end
