require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with a clerk_user_id" do
    expect(build(:user)).to be_valid
  end

  it "requires a unique clerk_user_id" do
    create(:user, clerk_user_id: "dup-1")
    expect(build(:user, clerk_user_id: "dup-1")).not_to be_valid
  end
end
