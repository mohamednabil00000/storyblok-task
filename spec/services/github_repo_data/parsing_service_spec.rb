# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubRepoData::ParsingService, type: :service do
  describe "#call" do
    let(:data) do
      [
        {
          "number" => 2,
          "state" => "open",
          "body" => "Issue body",
          "created_at" => "2024-01-01T00:00:00Z",
          "updated_at" => "2024-01-02T00:00:00Z",
          "title" => "Issue title",
          "id" => 102,
          "user" => {
            "login" => "testuser",
            "id" => 123,
            "avatar_url" => "https://avatars.githubusercontent.com/u/123?v=4",
            "url" => "https://api.github.com/users/testuser",
            "type" => "User"
          }
        },
        {
          "number" => 1,
          "state" => "open",
          "body" => "Issue body",
          "created_at" => "2024-01-01T00:00:00Z",
          "updated_at" => "2024-01-02T00:00:00Z",
          "title" => "Issue title",
          "id" => 101,
          "user" => {
            "login" => "testuser",
            "id" => 123,
            "avatar_url" => "https://avatars.githubusercontent.com/u/123?v=4",
            "url" => "https://api.github.com/users/testuser",
            "type" => "User"
          }
        }
      ]
    end
    let(:offset) { 101 }

    context "when offset is nil" do
      let(:offset) { nil }

      it "parses all the data and returns an array of issue attributes" do
        result = described_class.call(data:, offset:)
        expect(result).to be_success
        expect(result.payload[:offset_reached]).to be false
        expect(result.payload[:users]).to eq([
          {
            id: 123,
            login: "testuser",
            avatar_url: "https://avatars.githubusercontent.com/u/123?v=4",
            url: "https://api.github.com/users/testuser",
            user_type: "User"
          }
        ])

        expect(result.payload[:issues]).to eq([
          {
            id: 102,
            number: 2,
            title: "Issue title",
            state: "open",
            body: "Issue body",
            created_at: "2024-01-01T00:00:00Z",
            updated_at: "2024-01-02T00:00:00Z",
            user_id: 123
          },
          {
            id: 101,
            number: 1,
            title: "Issue title",
            state: "open",
            body: "Issue body",
            created_at: "2024-01-01T00:00:00Z",
            updated_at: "2024-01-02T00:00:00Z",
            user_id: 123
          }
        ])
      end
    end

    context "when offset is present" do
      let(:offset) { 101 }

      it "parses first row only" do
        result = described_class.call(data:, offset:)
        expect(result).to be_success
        expect(result.payload[:offset_reached]).to be true
        expect(result.payload[:users]).to eq([
          {
            id: 123,
            login: "testuser",
            avatar_url: "https://avatars.githubusercontent.com/u/123?v=4",
            url: "https://api.github.com/users/testuser",
            user_type: "User"
          }
        ])

        expect(result.payload[:issues]).to eq([
          {
            id: 102,
            number: 2,
            title: "Issue title",
            state: "open",
            body: "Issue body",
            created_at: "2024-01-01T00:00:00Z",
            updated_at: "2024-01-02T00:00:00Z",
            user_id: 123
          }
        ])
      end
    end
  end
end
