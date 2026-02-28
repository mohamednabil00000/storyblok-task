# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::IssuesController, type: :controller do
  describe "GET #index" do
    let(:user) { create(:user) }
    let!(:open_issue) { create(:issue, state: "open", user:, id: "1") }
    let!(:closed_issue) { create(:issue, state: "closed", user:, id: "5") }
    let(:json_response) { JSON.parse(response.body) }

    before { get :index, params: }

    context "without filters" do
      let(:params) { {} }

      it "returns all issues" do
        expect(response).to have_http_status(:ok)
        expect(json_response["issues"].size).to eq(2)
        expect(json_response.keys).to include("metadata", "issues")
        expect(json_response["issues"].first["id"]).to eq("5")
        expect(json_response["issues"].last["id"]).to eq("1")
        expect(response.headers["ISSUES_COUNT"]).to eq 2
      end
    end

    context "with state filter" do
      let(:params) { { state: "open" } }

      it "returns only open issues" do
        expect(response).to have_http_status(:ok)
        expect(json_response["issues"].size).to eq(1)
        expect(json_response["issues"].first["state"]).to eq("open")
        expect(response.headers["ISSUES_COUNT"]).to eq 2
      end
    end
  end
end
