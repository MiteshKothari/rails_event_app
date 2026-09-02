module Voting
  class CastVote
    Result = Struct.new(:success?, :error, keyword_init: true)

    DIRECTIONS = %i[up down].freeze

    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def call(event:, user:, direction:)
      return failure("invalid vote direction") unless DIRECTIONS.include?(direction)
      return failure("you have already voted on this event") if already_voted?(event, user)

      event_klass = direction == :up ? EventUpvoted : EventDownvoted
      event_store.publish(
        event_klass.new(data: { event_id: event.id, user_id: user.id }),
        stream_name: stream_name(event)
      )

      Result.new(success?: true, error: nil)
    end

    private

    attr_reader :event_store

    def already_voted?(event, user)
      event_store.read.stream(stream_name(event)).to_a.any? do |fact|
        fact.data.fetch(:user_id) == user.id
      end
    end

    def stream_name(event)
      "Event$#{event.id}"
    end

    def failure(message)
      Result.new(success?: false, error: message)
    end
  end
end
