FactoryBot.define do
  factory :event do
    sequence(:external_id) { |n| "ext-#{n}" }
    title { "Sample Event" }
    starts_at { 1.week.from_now }
    description { "A sample event." }
    image_url { "https://example.com/image.jpg" }
  end
end
