# frozen_string_literal: true

require "test_helper"

class TestGemRootFilter < Minitest::Test
  def test_gem_root_filter
    gem_path = Gem.path.first

    e = StandardError.new("test error")
    e.set_backtrace([
      "#{gem_path}/gems/minitest-5.14.0/lib/minitest/test.rb:3:in `block in <top (required)>'",
      "/test/middleware/test_gem_root_filter.rb:3:in `test_gem_root_filter'",
      "#{gem_path}/gems/turbo-rails-2.0.5/lib/turbo-rails.rb:3:in `block in <top (required)>'",
      "#{gem_path}/gems/turbo-turbo-rails-rails-2.0.5/lib/turbo-rails.rb:3:in `block in <top (required)>'",
      "#{gem_path}/gems/turbo_turbo_rails-2.0.5/lib/turbo-rails.rb:3:in `block in <top (required)>'"
    ])

    report = Telebugs::Report.new(e)
    Telebugs::Middleware::GemRootFilter.new.call(report)

    assert_equal [
      "minitest (5.14.0) lib/minitest/test.rb",
      "/test/middleware/test_gem_root_filter.rb",
      "turbo-rails (2.0.5) lib/turbo-rails.rb",
      "turbo-turbo-rails-rails (2.0.5) lib/turbo-rails.rb",
      "turbo_turbo_rails (2.0.5) lib/turbo-rails.rb"
    ], report.data[:errors].first[:backtrace].map { |f| f[:file] }
  end
end
