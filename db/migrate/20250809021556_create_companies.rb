# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.references :company_group, null: false, foreign_key: true

      t.timestamps
    end

    add_index :companies, [ :name, :company_group_id ], unique: true
    add_index :companies, [ :slug, :company_group_id ], unique: true
  end
end
