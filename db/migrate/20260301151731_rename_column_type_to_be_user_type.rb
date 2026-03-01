# frozen_string_literal: true

class RenameColumnTypeToBeUserType < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :type, :user_type
  end
end
