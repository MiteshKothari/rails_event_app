class Event < ApplicationRecord
  has_one :vote_tally

  validates :external_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :starts_at, presence: true
end
