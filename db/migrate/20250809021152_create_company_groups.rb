# frozen_string_literal: true

class CreateCompanyGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :company_groups do |t|
      t.string :name, null: false
      t.string :domain_name, null: false

      t.timestamps
    end
    add_index :company_groups, :domain_name, unique: true
  end
end
