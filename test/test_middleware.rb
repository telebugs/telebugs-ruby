# frozen_string_literal: true

require "test_helper"

class TestMiddleware < Minitest::Test
  def test_call
    assert_raises(NotImplementedError) do
      Telebugs::Middleware.new.call(nil)
    end
  end

  def test_weight
    assert_equal 0, Telebugs::Middleware.new.weight
  end
end
