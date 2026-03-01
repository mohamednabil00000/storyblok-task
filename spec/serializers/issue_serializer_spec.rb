# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueSerializer do
  let(:user) { create(:user) }
  let(:issue) { create(:issue, user:) }

  describe "#item" do
    subject { described_class.item(issue) }

    it "includes the issue's attributes" do
      expect(subject).to eq(
        id: issue.id,
        number: issue.number,
        state: issue.state,
        title: issue.title,
        body: issue.body,
        user: {
          id: user.id,
          login: user.login,
          avatar_url: user.avatar_url,
          url: user.url,
          type: user.user_type
        },
        created_at: issue.created_at,
        updated_at: issue.updated_at
      )
    end
  end

  describe "#collection" do
    let(:issues) { create_list(:issue, 3) }

    subject { described_class.collection(issues) }

    it "returns an array of serialized issues" do
      expect(subject).to eq(issues.map { |u| described_class.item(u) })
    end
  end
end
