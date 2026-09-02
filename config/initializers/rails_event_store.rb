Rails.application.config.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new

  Rails.configuration.event_store.subscribe(
    ReadModels::VoteTallyProjector.new,
    to: [Voting::EventUpvoted, Voting::EventDownvoted]
  )
end
