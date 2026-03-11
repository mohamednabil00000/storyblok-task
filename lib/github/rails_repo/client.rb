# frozen_string_literal: true

module Github
  module RailsRepo
    class Client
      BASE_URL = ENV.fetch("GITHUB_RAILS_REPO_BASE_URL", "https://api.github.com/repos/rails/rails")
      API_TOKEN = ENV.fetch("GITHUB_API_TOKEN", "your_default_token_here")

      Response = Struct.new(:success?, :payload, :error)

      class << self
        def get_issues(page: 1, cursor: nil)
          result = HTTParty.get(
            "#{BASE_URL}/issues?#{get_issues_query_params(page, cursor, 100)}",
            headers: auth_headers
          )

          if result.code == 200
            Response.new(
              true,
              {
                body: JSON.parse(result.body),
                after_cursor: result.headers["link"][/[?&]after=([^&>]+)/, 1]
              },
              nil
            )
          else
            Rails.logger.error("Failed to fetch issues: #{result.body}")
            Response.new(false, nil, "Failed to fetch issues: #{result.body}")
          end
        rescue StandardError => e
          Rails.logger.error("Error occurred: #{e.message}")
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

          def get_issues_query_params(page, cursor, per_page)
            params = []
            params << "page=#{page}"
            params << "per_page=#{per_page}"
            params << "is=issue"
            params << "state=all"
            params << cursor unless cursor.blank?

            params.join("&")
          end
      end
    end
  end
end
