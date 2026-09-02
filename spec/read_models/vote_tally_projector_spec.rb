require "rails_helper"

RSpec.describe ReadModels::VoteTallyProjector do
  let(:event_record) { create(:event) }

  it "creates a tally and increments up_count on EventUpvoted" do
    described_class.new.call(Voting::EventUpvoted.new(data: { event_id: event_record.id, user_id: 1 }))

    tally = VoteTally.find_by!(event_id: event_record.id)
    expect(tally.up_count).to eq(1)
    expect(tally.down_count).to eq(0)
  end

  it "increments down_count on EventDownvoted" do
    described_class.new.call(Voting::EventDownvoted.new(data: { event_id: event_record.id, user_id: 1 }))

    tally = VoteTally.find_by!(event_id: event_record.id)
    expect(tally.down_count).to eq(1)
  end

  it "accumulates counts across multiple calls" do
    2.times { described_class.new.call(Voting::EventUpvoted.new(data: { event_id: event_record.id, user_id: 1 })) }

    expect(VoteTally.find_by!(event_id: event_record.id).up_count).to eq(2)
  end

  it "is subscribed to Voting events, so publishing through the event store updates the tally automatically" do
    Rails.configuration.event_store.publish(
      Voting::EventUpvoted.new(data: { event_id: event_record.id, user_id: 1 }),
      stream_name: "Event$#{event_record.id}"
    )

    expect(VoteTally.find_by!(event_id: event_record.id).up_count).to eq(1)
  end
end
