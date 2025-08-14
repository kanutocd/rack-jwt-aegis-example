# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :middle_name
      t.references :company_group, null: false, foreign_key: true

      t.timestamps
    end

    add_index :users, [ :email, :company_group_id ], unique: true
  end
end
