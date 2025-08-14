# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :street_line_1
      t.string :street_line_2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.references :addressable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
