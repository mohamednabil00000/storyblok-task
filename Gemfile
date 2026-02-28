# frozen_string_literal: true

source "https://rubygems.org"

ruby "4.0.1"

gem "rails", "~> 8.1.0"
gem "pg", ">= 1.1"
gem "puma", ">= 7.0"
gem "bootsnap", require: false

# simplifies the syntax for making requests and is a popular choice for integrating with external APIs.
gem "httparty"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
  gem "rubocop-rails", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-rspec_rails", require: false
  gem "rspec-rails", "~> 6.1.3"
  gem "factory_bot_rails"
end

group :test do
  # VCR records HTTP interactions and replays them during test runs,
  # allowing you to test your code without making actual HTTP requests.
  gem "vcr"
  # WebMock allows you to stub HTTP requests and set expectations on them,
  # making it easier to test code that interacts with external APIs.
  gem "webmock"
  # Shoulda Matchers provides RSpec-compatible one-liners to test common Rails functionality,
  # such as validations and associations.
  gem "shoulda-matchers"
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "dotenv-rails", require: "dotenv/rails-now"
end
