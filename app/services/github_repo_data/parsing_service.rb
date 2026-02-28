# frozen_string_literal: true

class GithubRepoData::ParsingService < BaseService
  def initialize(data:, offset: nil)
    @data = data
    @offset = offset
  end

  def call
    @users = []
    @issues = []
    @offset_reached = false

    data.each do |issue_data|
      if issue_data["id"] == offset
        @offset_reached = true
        break
      end

      push_user_row!(issue_data["user"])
      push_issue_row!(issue_data)
    end

    @users.uniq! { |user| user[:id] }
    success(users: @users, issues: @issues, offset_reached: @offset_reached)
  rescue StandardError => e
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
        type: user_data["type"]
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
