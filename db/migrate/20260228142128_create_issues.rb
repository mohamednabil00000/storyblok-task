# frozen_string_literal: true

class CreateIssues < ActiveRecord::Migration[8.1]
  def change
    create_table :issues, id: :string do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.bigint :number, null: false
      t.string :state, null: false
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
