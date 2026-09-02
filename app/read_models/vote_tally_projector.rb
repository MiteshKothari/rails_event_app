module ReadModels
  class VoteTallyProjector
    def call(event)
      tally = VoteTally.find_or_create_by!(event_id: event.data.fetch(:event_id))
      tally.with_lock do
        column = event.is_a?(Voting::EventUpvoted) ? :up_count : :down_count
        tally.increment!(column)
      end
    end
  end
end
