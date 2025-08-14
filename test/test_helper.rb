# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require_relative 'support/simplecov'

require 'minitest/autorun'
require 'minitest/reporters'
require 'shoulda/context'
require 'shoulda/matchers'
require 'mocha/minitest'

require_relative 'support/aka_assert_nots'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
