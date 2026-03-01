# frozen_string_literal: true

class GithubRepoData::PersistingService < BaseService
  def initialize(users_data:, issues_data:)
    @users_data = users_data
    @issues_data = issues_data
  end

  def call
    ActiveRecord::Base.transaction do
      User.insert_all(users_data)
      Issue.insert_all!(issues_data)
    end

    success
  rescue StandardError => e
    failure("data persistence failed: #{e.message}")
  end

  private
    attr_accessor :users_data, :issues_data
end
