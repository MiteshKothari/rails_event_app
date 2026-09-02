require "rails_helper"

RSpec.describe Billetto::EventImporter do
  let(:client) { instance_double(Billetto::Client) }
  subject(:importer) { described_class.new(client: client) }

  it "creates a new Event for each valid record" do
    allow(client).to receive(:list_public_events).and_return(
      [
        {
          "id" => "1",
          "title" => "Rails Meetup",
          "description" => "A meetup",
          "startdate" => "2026-09-15T18:00:00Z",
          "image_link" => "https://example.com/a.jpg"
        }
      ]
    )

    result = importer.call

    expect(result.imported_count).to eq(1)
    expect(result.skipped_count).to eq(0)

    event = Event.find_by!(external_id: "1")
    expect(event.title).to eq("Rails Meetup")
    expect(event.image_url).to eq("https://example.com/a.jpg")
    expect(event.starts_at).to eq(Time.zone.parse("2026-09-15T18:00:00Z"))
  end

  it "is idempotent when re-run with the same records" do
    records = [{ "id" => "1", "title" => "Rails Meetup", "startdate" => "2026-09-15T18:00:00Z" }]
    allow(client).to receive(:list_public_events).and_return(records)

    importer.call
    expect { importer.call }.not_to change(Event, :count)
  end

  it "skips a record missing a required field and continues importing the rest" do
    allow(client).to receive(:list_public_events).and_return(
      [
        { "id" => "1", "title" => nil, "startdate" => "2026-09-15T18:00:00Z" },
        { "id" => "2", "title" => "Valid Event", "startdate" => "2026-09-15T18:00:00Z" }
      ]
    )

    result = importer.call

    expect(result.imported_count).to eq(1)
    expect(result.skipped_count).to eq(1)
    expect(Event.exists?(external_id: "2")).to be(true)
    expect(Event.exists?(external_id: "1")).to be(false)
  end
end
