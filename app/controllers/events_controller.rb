class EventsController < ApplicationController
  def index
    @events = Event.includes(:vote_tally).order(:starts_at)
  end
end
