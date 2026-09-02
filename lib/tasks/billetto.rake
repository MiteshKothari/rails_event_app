namespace :billetto do
  desc "Import events from the Billetto API"
  task import_events: :environment do
    result = Billetto::EventImporter.new.call
    puts "Imported #{result.imported_count} events, skipped #{result.skipped_count}"
  end
end
