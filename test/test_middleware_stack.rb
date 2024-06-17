# frozen_string_literal: true

require "test_helper"

class TestFilteringMiddleware < Telebugs::Middleware
  def call(report)
    report.data[:errors][0][:message] = "[FILTERED]"
  end

  def weight
    1
  end
end

class TestStartLineMiddleware < Telebugs::Middleware
  def call(report)
    report.data[:errors][0][:backtrace] = {123 => 456}
  end

  def weight
    10
  end
end

class TestMiddlewareStack < Minitest::Test
  def test_call
    stack = Telebugs::MiddlewareStack.new
    stack.use TestFilteringMiddleware.new
    stack.use TestStartLineMiddleware.new

    report = Telebugs::Report.new(StandardError.new("error message"))
    stack.call(report)

    assert_equal "[FILTERED]", report.data[:errors][0][:message]
    assert_equal({123 => 456}, report.data[:errors][0][:backtrace])
  end

  def test_weight
    stack = Telebugs::MiddlewareStack.new
    stack.use TestFilteringMiddleware.new
    stack.use TestStartLineMiddleware.new

    assert_equal(
      [TestStartLineMiddleware, TestFilteringMiddleware],
      stack.middlewares.map(&:class)
    )

    stack = Telebugs::MiddlewareStack.new
    stack.use TestStartLineMiddleware.new
    stack.use TestFilteringMiddleware.new

    assert_equal(
      [TestStartLineMiddleware, TestFilteringMiddleware],
      stack.middlewares.map(&:class)
    )
  end

  def test_delete
    stack = Telebugs::MiddlewareStack.new
    stack.use TestFilteringMiddleware.new
    stack.use TestStartLineMiddleware.new

    stack.delete TestFilteringMiddleware

    assert_equal [TestStartLineMiddleware], stack.middlewares.map(&:class)
  end
end
