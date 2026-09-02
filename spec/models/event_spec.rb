require "rails_helper"

RSpec.describe Event, type: :model do
  it "is valid with a title, external_id, and starts_at" do
    expect(build(:event)).to be_valid
  end

  it "requires a title" do
    expect(build(:event, title: nil)).not_to be_valid
  end

  it "requires an external_id" do
    expect(build(:event, external_id: nil)).not_to be_valid
  end

  it "requires starts_at" do
    expect(build(:event, starts_at: nil)).not_to be_valid
  end

  it "requires a unique external_id" do
    create(:event, external_id: "dup-1")
    expect(build(:event, external_id: "dup-1")).not_to be_valid
  end
end
