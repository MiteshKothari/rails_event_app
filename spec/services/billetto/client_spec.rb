require "rails_helper"

RSpec.describe Billetto::Client do
  subject(:client) { described_class.new(api_key: "test-key", base_url: "https://api.billetto.example/v3") }

  it "returns the events array on a successful response" do
    stub_request(:get, "https://api.billetto.example/v3/public/events")
      .to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: { object: "list", data: [{ "id" => "1", "title" => "Test Event" }] }.to_json
      )

    expect(client.list_public_events).to eq([{ "id" => "1", "title" => "Test Event" }])
  end

  it "sends the API key via the Api-Keypair header" do
    stub = stub_request(:get, "https://api.billetto.example/v3/public/events")
      .with(headers: { "Api-Keypair" => "test-key" })
      .to_return(status: 200, headers: { "Content-Type" => "application/json" }, body: { data: [] }.to_json)

    client.list_public_events

    expect(stub).to have_been_requested
  end

  it "raises Unauthorized on a 401 response" do
    stub_request(:get, "https://api.billetto.example/v3/public/events").to_return(status: 401)

    expect { client.list_public_events }.to raise_error(Billetto::Unauthorized)
  end

  it "raises RateLimited on a 429 response" do
    stub_request(:get, "https://api.billetto.example/v3/public/events").to_return(status: 429)

    expect { client.list_public_events }.to raise_error(Billetto::RateLimited)
  end

  it "raises UnexpectedResponse on a 500 response" do
    stub_request(:get, "https://api.billetto.example/v3/public/events").to_return(status: 500)

    expect { client.list_public_events }.to raise_error(Billetto::UnexpectedResponse)
  end

  it "raises UnexpectedResponse when the request times out" do
    stub_request(:get, "https://api.billetto.example/v3/public/events").to_timeout

    expect { client.list_public_events }.to raise_error(Billetto::UnexpectedResponse)
  end
end
