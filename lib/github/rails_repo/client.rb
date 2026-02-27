# frozen_string_literal: true

module Github
  module RailsRepo
    class Client
      BASE_URL = ENV.fetch("GITHUB_RAILS_REPO_BASE_URL", "https://api.github.com/repos/rails/rails")
      API_TOKEN = ENV.fetch("GITHUB_API_TOKEN", "your_default_token_here")

      Response = Struct.new(:success?, :payload, :error)

      class << self
        def get_issues(page: 1)
          result = HTTParty.get("#{BASE_URL}/issues?page=#{page}&per_page=50", headers: auth_headers)
          if result.code == 200
            Response.new(true, JSON.parse(result.body), nil)
          else
            Response.new(false, nil, "Failed to fetch issues: #{result.message}")
          end
        rescue StandardError => e
          Response.new(false, nil, "Error occurred: #{e.message}")
        end

        private
          def auth_headers
            {
              "Accept" => "application/vnd.github.v3+json",
              "Authorization" => "Bearer #{API_TOKEN}",
              "X-GitHub-Api-Version" => "2022-11-28"
            }
          end
      end
    end
  end
end
