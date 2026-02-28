# frozen_string_literal: true

FactoryBot.define do
  factory :issue do
    association :user
    id { "#{Random.rand(1..1000000)}}" }
    number { Random.rand(1..10000) }
    state { "open" }
    title { "Sample Issue" }
    body { "This is a sample issue for testing." }
  end
end
