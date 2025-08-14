# frozen_string_literal: true

class EmailAddress < ApplicationRecord
  belongs_to :emailable, polymorphic: true

  validates :emailable, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
