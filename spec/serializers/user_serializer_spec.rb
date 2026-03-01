# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSerializer do
  let(:user) { create(:user) }

  describe "#item" do
    subject { described_class.item(user) }

    it "includes the user's attributes" do
      expect(subject).to eq(
        id: user.id,
        login: user.login,
        avatar_url: user.avatar_url,
        url: user.url,
        type: user.user_type
      )
    end
  end

  describe "#collection" do
    let(:users) { create_list(:user, 3) }

    subject { described_class.collection(users) }

    it "returns an array of serialized users" do
      expect(subject).to eq(users.map { |u| described_class.item(u) })
    end
  end
end
