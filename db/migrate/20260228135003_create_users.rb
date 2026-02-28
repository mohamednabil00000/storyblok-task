# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: false do |t|
      t.primary_key :user_id, :bigint
      t.string :login
      t.string :avatar_url
      t.string :url
      t.string :type
      t.timestamps
    end
  end
end
