# frozen_string_literal: true

class CompanyGroup < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :companies, dependent: :destroy
  has_many :company_group_roles, dependent: :destroy

  validates :name, presence: true
  validates :domain_name, presence: true, uniqueness: true

  after_create :create_default_roles

  def assign_owner_role_to_first_user!
    return unless users.count == 1

    first_user = users.first
    owner_role = company_group_roles.find_by(name: 'Owner')

    first_user.company_group_roles << owner_role unless first_user.company_group_roles.include?(owner_role)
  end

  private

  def create_default_roles
    # CompanyGroup roles
    %w[Owner Admin CFO].each do |role_name|
      company_group_roles.create!(
        name: role_name
      )
    end
  end
end
