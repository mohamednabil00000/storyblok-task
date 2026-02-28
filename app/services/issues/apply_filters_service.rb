# frozen_string_literal: true

class Issues::ApplyFiltersService < BaseService
  def initialize(issues:, filter_params:)
    @issues = issues
    @filter_params = filter_params
  end

  def call
    @issues = @issues.where(state: filter_params[:state]) if filter_params[:state].present?
    success(issues)
  end

  private
    attr_accessor :issues, :filter_params
end
