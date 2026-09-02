require "rails_helper"

RSpec.describe "Sessions", type: :request do
  xit "signs a user in and redirects to the events list with a confirmation" do
    post session_path, params: { email: "person@example.com" }

    expect(response).to redirect_to(events_path)
    follow_redirect!
    expect(response.body).to include("Signed in as person@example.com")
  end

  xit "signs a user out and redirects to the events list" do
    post session_path, params: { email: "person@example.com" }
    delete session_path

    expect(response).to redirect_to(events_path)
    follow_redirect!
    expect(response.body).to include("Signed out")
  end
end
