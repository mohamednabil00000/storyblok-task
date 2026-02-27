# frozen_string_literal: true

source "https://rubygems.org"

ruby "4.0.1"

gem "rails", "~> 8.1.0"
gem "pg", ">= 1.1"
gem "puma", ">= 7.0"
gem "bootsnap", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
  gem "rubocop-rails", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-rspec_rails", require: false
  gem "rspec-rails", "~> 6.1.3"
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
