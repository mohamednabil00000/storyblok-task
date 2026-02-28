# frozen_string_literal: true

class User < ApplicationRecord
  has_many :issues, dependent: :destroy_async, inverse_of: :user
end
