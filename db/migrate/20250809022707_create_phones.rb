# frozen_string_literal: true

class CreatePhones < ActiveRecord::Migration[8.0]
  def change
    create_table :phones do |t|
      t.string :phone_number
      t.string :extension
      t.string :phone_type
      t.string :label
      t.references :phoneable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
