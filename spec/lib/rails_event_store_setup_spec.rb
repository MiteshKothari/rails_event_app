require "rails_helper"

RSpec.describe "Rails Event Store setup" do
  class SmokeTestEvent < RubyEventStore::Event
  end

  it "publishes and reads back an event with the expected data" do
    event_store = Rails.configuration.event_store

    event_store.publish(
      SmokeTestEvent.new(data: { hello: "world" }),
      stream_name: "SmokeTest$1"
    )

    facts = event_store.read.stream("SmokeTest$1").to_a

    expect(facts.size).to eq(1)
    expect(facts.first.data).to eq(hello: "world")
  end
end
