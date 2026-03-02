# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubIssuesSynchronizerJob, type: :job do
  let(:redis) { instance_double(Redis, get: nil, set: "OK") }

  before do
    # Ensure the job uses a test double instead of a real Redis connection
    $redis = redis
  end

  describe "#perform" do
    let(:raw_issues_page1) do
      {
        body: [
          {
            "id" => 456,
            "number" => 1,
            "title" => "Issue title",
            "state" => "open",
            "body" => "Body",
            "created_at" => "2024-01-01T00:00:00Z",
            "updated_at" => "2024-01-02T00:00:00Z",
            "user" => {
              "id" => 123,
              "login" => "user1",
              "avatar_url" => "https://example.com/avatar",
              "url" => "https://api.github.com/users/1",
              "type" => "User"
            }
          }
        ],
        after_cursor: 12345,
        before_cursor: nil
      }
    end

    let(:parsed_payload) do
      {
        users: [
          {
            id: 123,
            login: "user1",
            avatar_url: "https://example.com/avatar",
            url: "https://api.github.com/users/1",
            user_type: "User"
          }
        ],
        issues: [
          {
            id: 456,
            number: 1,
            title: "Issue title",
            state: "open",
            body: "Body",
            created_at: "2024-01-01T00:00:00Z",
            updated_at: "2024-01-02T00:00:00Z",
            user_id: 123
          }
        ],
        offset_reached: true,
        recent_issue_id: 456
      }
    end

    context "when all steps succeed and offset is reached" do
      before do
        allow(Github::RailsRepo::Client).to receive(:get_issues).with(page: 1, cursor: nil).and_return(
          double(success?: true, payload: raw_issues_page1)
        )
        allow(GithubRepoData::ParsingService).to receive(:call).and_return(
          double(success?: true, payload: parsed_payload)
        )
        allow(GithubRepoData::PersistingService).to receive(:call).with(
          users_data: parsed_payload[:users],
          issues_data: parsed_payload[:issues]
        ).and_return(double(success?: true))
      end

      it "fetches issues, parses, persists, and sets last_issue_id in Redis" do
        described_class.perform_now

        expect(Github::RailsRepo::Client).to have_received(:get_issues).with(page: 1, cursor: nil)
        expect(GithubRepoData::ParsingService).to have_received(:call)
        expect(GithubRepoData::PersistingService).to have_received(:call)
        expect(redis).to have_received(:set).with("last_issue_id", 456)
      end

      it "uses last_issue_id from Redis when present" do
        allow(redis).to receive(:get).with("last_issue_id").and_return("100")

        described_class.perform_now

        expect(GithubRepoData::ParsingService).to have_received(:call).with(
          data: raw_issues_page1[:body],
          offset: "100"
        )
      end
    end

    context "when first page returns empty issues" do
      before do
        allow(Github::RailsRepo::Client).to receive(:get_issues).with(page: 1, cursor: nil).and_return(
          double(success?: true, payload: { body: [], before_cursor: nil, after_cursor: nil })
        )
        allow(GithubRepoData::ParsingService).to receive(:call).and_return(
          double(success?: true, payload: { users: [], issues: [], offset_reached: false })
        )
      end

      it "exits the loop and does not set last_issue_id" do
        described_class.perform_now

        expect(redis).not_to have_received(:set)
      end
    end

    context "when get_issues fails" do
      before do
        allow(Github::RailsRepo::Client).to receive(:get_issues).with(page: 1, cursor: nil).and_return(
          double(success?: false)
        )
        allow(GithubRepoData::ParsingService).to receive(:call)
      end

      it "returns early and does not set last_issue_id" do
        described_class.perform_now

        expect(GithubRepoData::ParsingService).not_to have_received(:call)
        expect(redis).not_to have_received(:set)
      end
    end

    context "when ParsingService fails" do
      before do
        allow(Github::RailsRepo::Client).to receive(:get_issues).with(page: 1, cursor: nil).and_return(
          double(success?: true, payload: raw_issues_page1)
        )
        allow(GithubRepoData::ParsingService).to receive(:call).and_return(
          double(success?: false)
        )
        allow(GithubRepoData::PersistingService).to receive(:call)
      end

      it "returns early and does not set last_issue_id" do
        described_class.perform_now

        expect(GithubRepoData::PersistingService).not_to have_received(:call)
        expect(redis).not_to have_received(:set)
      end
    end

    context "when PersistingService fails" do
      before do
        allow(Github::RailsRepo::Client).to receive(:get_issues).with(page: 1, cursor: nil).and_return(
          double(success?: true, payload: raw_issues_page1)
        )
        allow(GithubRepoData::ParsingService).to receive(:call).and_return(
          double(success?: true, payload: parsed_payload)
        )
        allow(GithubRepoData::PersistingService).to receive(:call).and_return(
          double(success?: false)
        )
      end

      it "returns early and does not set last_issue_id" do
        described_class.perform_now

        expect(redis).not_to have_received(:set)
      end
    end

    context "when multiple pages are fetched" do
      let(:raw_issues_page2) do
        {
        body: [
          {
            "id" => 455,
            "number" => 2,
            "title" => "Older issue",
            "state" => "open",
            "body" => "Body",
            "created_at" => "2024-01-01T00:00:00Z",
            "updated_at" => "2024-01-02T00:00:00Z",
            "user" => {
              "id" => 123,
              "login" => "user1",
              "avatar_url" => "https://example.com/avatar",
              "url" => "https://api.github.com/users/1",
              "type" => "User"
            }
          }
        ],
        after_cursor: nil,
        before_cursor: nil
      }
      end

      let(:parsed_page1) do
        {
          users: [
            {
              id: 123,
              login: "user1",
              avatar_url: "https://example.com/avatar",
              url: "https://api.github.com/users/1",
              user_type: "User"
            }
          ],
          issues: [
            {
              id: 456,
              number: 1,
              title: "Issue title",
              state: "open",
              body: "Body",
              created_at: "2024-01-01T00:00:00Z",
              updated_at: "2024-01-02T00:00:00Z",
              user_id: 123
            }
          ],
          offset_reached: false,
          recent_issue_id: 456
        }
      end

      let(:parsed_page2) do
        {
          users: parsed_page1[:users],
          issues: [
            {
              id: 455,
              number: 2,
              title: "Older issue",
              state: "open",
              body: "Body",
              created_at: "2024-01-01T00:00:00Z",
              updated_at: "2024-01-02T00:00:00Z",
              user_id: 123
            }
          ],
          offset_reached: true,
          recent_issue_id: 455
        }
      end

      before do
        allow(Github::RailsRepo::Client).to receive(:get_issues).with(page: 1, cursor: nil).and_return(
          double(success?: true, payload: raw_issues_page1)
        )
        allow(Github::RailsRepo::Client).to receive(:get_issues).with(page: 2, cursor: "after=12345").and_return(
          double(success?: true, payload: raw_issues_page2)
        )
        allow(GithubRepoData::ParsingService).to receive(:call).and_return(
          double(success?: true, payload: parsed_page1),
          double(success?: true, payload: parsed_page2)
        )
        allow(GithubRepoData::PersistingService).to receive(:call).and_return(
          double(success?: true)
        )
      end

      it "paginates and sets last_issue_id to the first issue id from the first page" do
        described_class.perform_now

        expect(Github::RailsRepo::Client).to have_received(:get_issues).with(page: 1, cursor: nil)
        expect(Github::RailsRepo::Client).to have_received(:get_issues).with(page: 2, cursor: "after=12345")
        expect(redis).to have_received(:set).with("last_issue_id", 456)
      end
    end
  end
end
