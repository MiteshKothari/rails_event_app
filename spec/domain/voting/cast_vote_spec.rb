require "rails_helper"

RSpec.describe Voting::CastVote do
  let(:event) { create(:event) }
  let(:user) { create(:user) }
  subject(:cast_vote) { described_class.new }

  it "publishes an EventUpvoted fact with the event and user ids" do
    result = cast_vote.call(event: event, user: user, direction: :up)

    expect(result.success?).to be(true)
    fact = Rails.configuration.event_store.read.stream("Event$#{event.id}").to_a.last
    expect(fact).to be_a(Voting::EventUpvoted)
    expect(fact.data).to eq(event_id: event.id, user_id: user.id)
  end

  it "publishes an EventDownvoted fact for a down vote" do
    result = cast_vote.call(event: event, user: user, direction: :down)

    expect(result.success?).to be(true)
    fact = Rails.configuration.event_store.read.stream("Event$#{event.id}").to_a.last
    expect(fact).to be_a(Voting::EventDownvoted)
  end

  it "rejects a second vote from the same user on the same event" do
    cast_vote.call(event: event, user: user, direction: :up)
    result = cast_vote.call(event: event, user: user, direction: :down)

    expect(result.success?).to be(false)
    expect(result.error).to match(/already voted/)
  end

  it "rejects an invalid direction" do
    result = cast_vote.call(event: event, user: user, direction: :sideways)

    expect(result.success?).to be(false)
  end

  it "increments the event's vote tally via the projector" do
    expect { cast_vote.call(event: event, user: user, direction: :up) }
      .to change { event.reload.vote_tally&.up_count }.from(nil).to(1)
  end
end
