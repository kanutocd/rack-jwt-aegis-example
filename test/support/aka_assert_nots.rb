# frozen_string_literal: true

# Add assert_not aliases for refute methods
Minitest::Test.include(Module.new do
  def assert_not(object, message = nil)
    refute(object, message)
  end

  def assert_not_includes(collection, object, message = nil)
    refute_includes(collection, object, message)
  end

  def assert_not_nil(object, message = nil)
    refute_nil(object, message)
  end
end)

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
