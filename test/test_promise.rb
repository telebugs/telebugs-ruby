# frozen_string_literal: true

require "test_helper"

class TestPromise < Minitest::Test
  def test_value
    p = Telebugs::Promise.new { 1 + 1 }

    assert_equal 2, p.value
  end

  def test_reason
    p = Telebugs::Promise.new { raise "error" }

    assert_equal "error", p.reason.message
  end

  def test_fulfilled
    p = Telebugs::Promise.new { 1 + 1 }
    p.wait

    assert p.fulfilled?
  end

  def test_rejected
    p = Telebugs::Promise.new { raise "error" }
    p.wait

    assert p.rejected?
  end
end
