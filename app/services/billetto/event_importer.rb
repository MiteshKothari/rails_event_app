module Billetto
  class EventImporter
    Result = Struct.new(:imported_count, :skipped_count, keyword_init: true)

    def initialize(client: Rails.configuration.billetto_client)
      @client = client
    end

    def call
      imported = 0
      skipped = 0

      client.list_public_events.each do |record|
        if import_record(record)
          imported += 1
        else
          skipped += 1
        end
      end

      Result.new(imported_count: imported, skipped_count: skipped)
    end

    private

    attr_reader :client

    def import_record(record)
      event = Event.find_or_initialize_by(external_id: record.fetch("id").to_s)
      event.assign_attributes(
        title: record["title"],
        description: record["description"],
        starts_at: record["startdate"],
        image_url: record["image_link"]
      )
      event.save!
      true
    rescue ActiveRecord::RecordInvalid, KeyError => e
      Rails.logger.warn("[Billetto::EventImporter] Skipping invalid record #{record["id"].inspect}: #{e.message}")
      false
    end
  end
end
