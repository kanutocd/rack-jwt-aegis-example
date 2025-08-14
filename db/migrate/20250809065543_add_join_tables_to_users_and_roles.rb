# frozen_string_literal: true

class AddJoinTablesToUsersAndRoles < ActiveRecord::Migration[8.0]
  def change
    create_join_table :company_group_roles, :users do |t|
      t.index :company_group_role_id
      t.index :user_id
    end

    create_join_table :company_roles, :company_users do |t|
      t.index :company_role_id
      t.index :company_user_id
    end
  end
end
