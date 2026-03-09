# frozen_string_literal: true

class RemoveIndexCreatedAt < ActiveRecord::Migration[8.1]
  def change
    remove_index :issues, column: :created_at
  end
end
