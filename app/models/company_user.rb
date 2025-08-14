# frozen_string_literal: true

class CompanyUser < ApplicationRecord
  belongs_to :user
  belongs_to :company
  has_and_belongs_to_many :company_roles

  validates :user_id, uniqueness: { scope: :company_id }
end
