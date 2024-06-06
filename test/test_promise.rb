# frozen_string_literal: true

require "test_helper"

class TestPromise < Minitest::Test
  def test_future_value
    promise = Telebugs::Promise.new { 1 + 1 }

    assert_equal 2, promise.value
  end
end
