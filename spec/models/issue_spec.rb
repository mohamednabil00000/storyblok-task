# frozen_string_literal: true

require "rails_helper"

RSpec.describe Issue, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).inverse_of(:issues) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:state) }
  end

  describe "scopes" do
    describe ".ordered" do
      let!(:issue1) { create(:issue, id: 1) }
      let!(:issue2) { create(:issue, id: 2) }
      let!(:issue3) { create(:issue, id: 3) }

      it "returns issues ordered by id in descending order" do
        expect(Issue.ordered).to eq([issue3, issue2, issue1])
      end
    end
  end
end
