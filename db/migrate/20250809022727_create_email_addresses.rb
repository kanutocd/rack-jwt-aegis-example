# frozen_string_literal: true

class CreateEmailAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :email_addresses do |t|
      t.string :email
      t.string :label
      t.references :emailable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
