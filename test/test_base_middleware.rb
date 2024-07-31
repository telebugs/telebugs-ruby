# frozen_string_literal: true

require "test_helper"

class TestBaseMiddleware < Minitest::Test
  def test_call
    assert_raises(NotImplementedError) do
      Telebugs::BaseMiddleware.new.call(nil)
    end
  end

  def test_weight
    assert_equal 0, Telebugs::BaseMiddleware.new.weight
  end
end
