require "rails_helper"

RSpec.describe "Votes", type: :request do
  let(:event) { create(:event) }

  xit "redirects to sign in when not authenticated" do
    post event_votes_path(event), params: { direction: "up" }

    expect(response).to redirect_to("/session/new")
  end

  xit "records a vote and updates the tally for a signed-in user" do
    post session_path, params: { email: "voter@example.com" }

    post event_votes_path(event), params: { direction: "up" }

    expect(response).to redirect_to(events_path)
    expect(event.reload.vote_tally.up_count).to eq(1)
  end

  xit "rejects a second vote from the same signed-in user" do
    post session_path, params: { email: "voter@example.com" }
    post event_votes_path(event), params: { direction: "up" }

    post event_votes_path(event), params: { direction: "down" }
    follow_redirect!

    expect(response.body).to include("already voted")
    expect(event.reload.vote_tally.up_count).to eq(1)
    expect(event.reload.vote_tally.down_count).to eq(0)
  end

  xit "rejects an invalid direction" do
    post session_path, params: { email: "voter@example.com" }

    post event_votes_path(event), params: { direction: "sideways" }

    expect(response).to redirect_to(events_path)
    expect(event.reload.vote_tally).to be_nil
  end
end
