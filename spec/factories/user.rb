# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    user_id { Random.rand(1..1000) }
    login { "test_user" }
    avatar_url { "https://example.com/avatar.png" }
    url { "https://example.com/user" }
    type { "User" }
  end
end
