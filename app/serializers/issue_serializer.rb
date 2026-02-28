# frozen_string_literal: true

class IssueSerializer < BaseSerializer
  def self.item(issue)
    {
      id: issue.id,
      number: issue.number,
      state: issue.state,
      title: issue.title,
      body: issue.body,
      user: UserSerializer.item(issue.user),
      created_at: issue.created_at,
      updated_at: issue.updated_at
    }
  end
end
