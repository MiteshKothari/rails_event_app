require "rails_helper"

RSpec.describe "Voting on events", type: :system do
  xit "lets a signed-in user vote and see the count update" do
    create(:event, title: "Rails Meetup")

    visit new_session_path
    fill_in "Email", with: "voter@example.com"
    click_button "Sign in"

    expect(page).to have_content("Rails Meetup")
    expect(page).to have_content("Up: 0")

    click_button "Upvote"

    expect(page).to have_content("Up: 1")
  end

  xit "does not let a signed-out visitor vote" do
    create(:event, title: "Rails Meetup")

    visit events_path
    click_button "Upvote"

    expect(page).to have_content("Sign in")
  end
end
