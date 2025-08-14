# frozen_string_literal: true

class CompanyGroupRole < ApplicationRecord
  belongs_to :company_group
  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: { scope: [ :company_group_id ] }
end
