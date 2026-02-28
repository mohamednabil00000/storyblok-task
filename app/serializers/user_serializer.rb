# frozen_string_literal: true

class UserSerializer < BaseSerializer
  def self.item(user)
    {
      id: user.id,
      login: user.login,
      avatar_url: user.avatar_url,
      url: user.url,
      type: user.type
    }
  end
end
