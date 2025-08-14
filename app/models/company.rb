# frozen_string_literal: true

class Company < ApplicationRecord
  belongs_to :company_group
  has_many :company_users, dependent: :destroy
  has_many :users, through: :company_users
  has_many :company_roles, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :company_group_id }
  validates :slug, presence: true, uniqueness: { scope: :company_group_id },
            format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: 'must be URL-safe (lowercase letters, numbers, hyphens)' }

  before_validation :generate_slug, if: -> { name.present? && (slug.blank? || name_changed?) }
  after_create :create_default_roles

  private

  def generate_slug
    base_slug = name.parameterize
    candidate_slug = base_slug
    counter = 1

    while company_group.companies.where(slug: candidate_slug).where.not(id: id).exists?
      candidate_slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = candidate_slug
  end

  def create_default_roles
    # Company roles (same as CompanyGroup roles)
    %w[Admin Ordinary].each do |role_name|
      company_roles.create!(
        name: role_name
      )
    end
  end
end
