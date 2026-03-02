# frozen_string_literal: true

class GithubRepoData::ParsingService < BaseService
  def initialize(data:, offset: nil)
    @data = data
    @offset = offset&.to_s
  end

  def call
    @users = []
    @issues = []
    @offset_reached = false
    @recent_issue_id = nil

    data.each do |issue_data|
      if offset && issue_data["id"].to_s == offset
        @offset_reached = true
        break
      end

      @recent_issue_id = issue_data["id"] unless @recent_issue_id

      next if issue_data.key?("pull_request") # skip if the row is a pull request

      push_user_row!(issue_data["user"])
      push_issue_row!(issue_data)
    end

    @users.uniq! { |user| user[:id] }
    success(users: @users, issues: @issues, offset_reached: @offset_reached, recent_issue_id: @recent_issue_id)
  rescue StandardError => e
    Rails.logger.error("data parsing failed: #{e.message}")
    failure("data parsing failed: #{e.message}")
  end

  private
    attr_accessor :data, :offset

    def push_user_row!(user_data)
      @users << {
        id: user_data["id"],
        login: user_data["login"],
        avatar_url: user_data["avatar_url"],
        url: user_data["url"],
        user_type: user_data["type"]
      }
    end

    def push_issue_row!(issue_data)
      @issues << {
        id: issue_data["id"],
        number: issue_data["number"],
        title: issue_data["title"],
        state: issue_data["state"],
        body: issue_data["body"],
        created_at: issue_data["created_at"],
        updated_at: issue_data["updated_at"],
        user_id: issue_data["user"]["id"]
      }
    end
end
