# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubRepoData::PersistingService, type: :service do
  describe "#call" do
    let(:users_data) do
      [
        {
          id: 123,
          login: "testuser",
          avatar_url: "https://avatars.githubusercontent.com/u/123?v=4",
          url: "https://api.github.com/users/testuser",
          user_type: "User"
        }
      ]
    end
    let(:issues_data) do
      [
        {
          id: 101,
          number: 1,
          state: "open",
          body: "Issue body",
          created_at: "2024-01-01T00:00:00Z",
          updated_at: "2024-01-02T00:00:00Z",
          title: "Issue title",
          user_id: 123
        }
      ]
    end

    context "when the data does not have a duplicate" do
      it "persists the users and issues data into the database" do
        expect do
          result = described_class.call(users_data:, issues_data:)
          expect(result).to be_success
        end.to change(User, :count).by(1)
            .and change(Issue, :count).by(1)
      end
    end

    context "when we have a duplicate in users data" do
      let(:users_data) do
        [
          {
            id: 123,
            login: "testuser",
            avatar_url: "https://avatars.githubusercontent.com/u/123?v=4",
            url: "https://api.github.com/users/testuser",
            user_type: "User"
          },
          {
            id: 123,
            login: "testuser",
            avatar_url: "https://avatars.githubusercontent.com/u/123?v=4",
            url: "https://api.github.com/users/testuser",
            user_type: "User"
          }
        ]
      end

      it "only one will be persisted" do
        expect do
          result = described_class.call(users_data:, issues_data:)
          expect(result).to be_success
        end.to change(User, :count).by(1)
            .and change(Issue, :count).by(1)
      end
    end

    context "when we have a duplicate in issues data" do
      let(:issues_data) do
        [
          {
            id: 101,
            number: 1,
            state: "open",
            body: "Issue body",
            created_at: "2024-01-01T00:00:00Z",
            updated_at: "2024-01-02T00:00:00Z",
            title: "Issue title",
            user_id: 123
          },
          {
            id: 101,
            number: 1,
            state: "open",
            body: "Issue body",
            created_at: "2024-01-01T00:00:00Z",
            updated_at: "2024-01-02T00:00:00Z",
            title: "Issue title",
            user_id: 123
          }
        ]
      end

      it "doesn't persist the data and return failure" do
        expect do
          result = described_class.call(users_data:, issues_data:)
          expect(result).not_to be_success
          expect(result.error).to include "duplicate key value"
        end.to change(User, :count).by(0)
            .and change(Issue, :count).by(0)
      end
    end

    context "when I have a duplicate but one already persisted in db and one new" do
      let!(:existed_user) { create(:user, id: 123) }

      it "persists the users and issues data into the database" do
        expect do
          result = described_class.call(users_data:, issues_data:)
          expect(result).to be_success
        end.to change(User, :count).by(0)
            .and change(Issue, :count).by(1)
      end
    end
  end
end
