require "rails_helper"

RSpec.describe VoteTally, type: :model do
  it "defaults up_count and down_count to 0" do
    tally = VoteTally.create!(event: create(:event))

    expect(tally.up_count).to eq(0)
    expect(tally.down_count).to eq(0)
  end

  it "belongs to an event, reachable from Event#vote_tally" do
    event = create(:event)
    tally = VoteTally.create!(event: event)

    expect(event.reload.vote_tally).to eq(tally)
  end
end
