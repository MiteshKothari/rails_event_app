require "rails_helper"

RSpec.describe "Events", type: :request do
  it "lists events with title, date, description, and a default vote count of 0" do
    create(:event, title: "Rails Meetup", description: "Come learn Rails", starts_at: Time.zone.parse("2026-09-15 18:00"))

    get events_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Rails Meetup")
    expect(response.body).to include("Come learn Rails")
    expect(response.body).to include("Up: 0")
    expect(response.body).to include("Down: 0")
  end
end
