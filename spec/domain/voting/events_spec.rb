require "rails_helper"

RSpec.describe "Voting events" do
  it "Voting::EventUpvoted is a RubyEventStore::Event carrying event_id and user_id" do
    event = Voting::EventUpvoted.new(data: { event_id: 1, user_id: 2 })

    expect(event).to be_a(RubyEventStore::Event)
    expect(event.data).to eq(event_id: 1, user_id: 2)
  end

  it "Voting::EventDownvoted is a RubyEventStore::Event carrying event_id and user_id" do
    event = Voting::EventDownvoted.new(data: { event_id: 1, user_id: 2 })

    expect(event).to be_a(RubyEventStore::Event)
    expect(event.data).to eq(event_id: 1, user_id: 2)
  end
end
