# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates :addressable, presence: true
  validates :street_line_1, presence: true
  validates :city, presence: true
  validates :country, presence: true
end
