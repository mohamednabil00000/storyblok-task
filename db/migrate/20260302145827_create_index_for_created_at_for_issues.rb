# frozen_string_literal: true

class CreateIndexForCreatedAtForIssues < ActiveRecord::Migration[8.1]
  def change
    add_index :issues, :created_at
  end
end
