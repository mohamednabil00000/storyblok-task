# frozen_string_literal: true

class Issue < ApplicationRecord
  belongs_to :user, inverse_of: :issues

  validates :number, presence: true
  validates :state, presence: true
end
