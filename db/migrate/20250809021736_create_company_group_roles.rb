# frozen_string_literal: true

class CreateCompanyGroupRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :company_group_roles do |t|
      t.string :name, null: false
      t.text :description
      t.references :company_group, null: false, foreign_key: true

      t.timestamps
    end

    add_index :company_group_roles, [ :name, :company_group_id ], unique: true
  end
end
