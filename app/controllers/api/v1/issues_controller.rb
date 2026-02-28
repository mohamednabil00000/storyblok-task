# frozen_string_literal: true

class Api::V1::IssuesController < Api::BaseController
  # GET /api/v1/issues?page=1&state=open
  def index
    issues = Issue.includes(:user)
    result = Issues::ApplyFiltersService.call(issues:, filter_params:)
    if result.success?
      set_issue_count_header!(issues.size)
      pagy, issues = pagy(result.payload.ordered)
      render json: { issues: IssueSerializer.collection(issues), metadata: pagy.data_hash }, status: :ok
    else
      render json: { errors: result.error }, status: :bad_request
    end
  end

  private
    def filter_params
      params.permit(:state)
    end

    def set_issue_count_header!(count)
      response.headers["ISSUES_COUNT"] = count
    end
end
