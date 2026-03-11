# frozen_string_literal: true

require "rails_helper"

RSpec.describe Github::RailsRepo::Client do
  before do
    # Ensure that the environment variables are set for testing
    stub_const("Github::RailsRepo::Client::BASE_URL", "https://api.github.com/repos/rails/rails")
    stub_const("Github::RailsRepo::Client::API_TOKEN", "token")
  end

  context "when fetching issues successfully" do
    it "fetches the rails repo issues", vcr: { cassette_name: "github/rails_repo/success/returns_ok" } do
      result = Github::RailsRepo::Client.get_issues
      expect(result.success?).to be true
      expect(result.payload[:body]).to be_an(Array)
      expect(result.payload[:after_cursor]).not_to be_nil
    end
  end

  context "when fetching issues fails" do
    it "when the API is not authenticated", vcr: { cassette_name: "github/rails_repo/failure/returns_401" } do
      stub_const("Github::RailsRepo::Client::API_TOKEN", "invalid_token")
      result = Github::RailsRepo::Client.get_issues
      expect(result.success?).to be false
      expect(result.error).to include("Failed to fetch issues")
    end
  end
end
