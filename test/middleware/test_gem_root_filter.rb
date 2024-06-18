# frozen_string_literal: true

require "test_helper"

class TestGemRootFilter < Minitest::Test
  def test_gem_root_filter
    begin
      raise StandardError.new("test error")
    rescue => e
      report = Telebugs::Report.new(e)
    end

    Telebugs::Middleware::GemRootFilter.new.call(report)

    assert_match(
      %r{/test/middleware/test_gem_root_filter.rb},
      report.data[:errors][0][:backtrace][0][:file]
    )
    assert_match(
      %r{\Aminitest \(.+\..+\..+\) lib/minitest/test.rb\z},
      report.data[:errors][0][:backtrace][1][:file]
    )
  end
end
