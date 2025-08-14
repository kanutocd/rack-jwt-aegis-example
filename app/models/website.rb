# frozen_string_literal: true

class Website < ApplicationRecord
  belongs_to :websitable, polymorphic: true

  validates :websitable, presence: true
  validates :url, presence: true, format: { with: URI.regexp(%w[http https]) }
end
