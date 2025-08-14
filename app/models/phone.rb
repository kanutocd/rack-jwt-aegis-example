# frozen_string_literal: true

class Phone < ApplicationRecord
  belongs_to :phoneable, polymorphic: true

  validates :phoneable, presence: true
  validates :phone_number, presence: true
end
