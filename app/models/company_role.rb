# frozen_string_literal: true

class CompanyRole < ApplicationRecord
  belongs_to :company
  has_and_belongs_to_many :company_users
  validates :name, presence: true, uniqueness: { scope: [ :company_id ] }
end
