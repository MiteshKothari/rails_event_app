class VotesController < ApplicationController
  before_action :require_authentication!

  VALID_DIRECTIONS = %w[up down].freeze

  def create
    event = Event.find(params[:event_id])

    unless VALID_DIRECTIONS.include?(params[:direction])
      return redirect_to(events_path, alert: "Invalid vote direction")
    end

    result = Voting::CastVote.new.call(event: event, user: current_user, direction: params[:direction].to_sym)

    if result.success?
      redirect_to events_path, notice: "Vote recorded"
    else
      redirect_to events_path, alert: result.error
    end
  end
end
