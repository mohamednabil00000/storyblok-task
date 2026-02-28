# frozen_string_literal: true

require "rails_helper"

RSpec.describe Issues::ApplyFiltersService, type: :service do
  describe "#call" do
    let(:user) { create(:user) }
    let!(:open_issues) { create_list(:issue, 3, user:, state: "open") }
    let!(:closed_issues) { create_list(:issue, 2, user:, state: "closed") }

    context "when state filter is present" do
      let(:filter_params) { { state: "open" } }

      it "returns issues with the specified state" do
        result = described_class.call(issues: Issue.all, filter_params:)
        expect(result).to be_success
        expect(result.payload.size).to eq(3)
        expect(result.payload).to all(have_attributes(state: "open"))
      end
    end

    context "when state filter is not present" do
      let(:filter_params) { {} }

      it "returns all issues" do
        result = described_class.call(issues: Issue.all, filter_params:)
        expect(result).to be_success
        expect(result.payload.size).to eq(5)
        expect(result.payload).to match_array(Issue.all)
      end
    end
  end
end
