FactoryBot.define do
  factory :user do
    sequence(:clerk_user_id) { |n| "user_#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
  end
end
