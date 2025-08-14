# frozen_string_literal: true

class CreateWebsites < ActiveRecord::Migration[8.0]
  def change
    create_table :websites do |t|
      t.string :url
      t.string :label
      t.references :websitable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
