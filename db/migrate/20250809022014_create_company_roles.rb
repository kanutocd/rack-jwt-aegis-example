# frozen_string_literal: true

class CreateCompanyRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :company_roles do |t|
      t.string :name, null: false
      t.text :description
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end

    add_index :company_roles, [ :name, :company_id ], unique: true
  end
end
