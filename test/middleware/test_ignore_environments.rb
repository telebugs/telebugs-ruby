# frozen_string_literal: true

require "test_helper"

class TestIgnoreEnvironments < Minitest::Test
  def test_ignore_environments_when_env_matches
    report = Telebugs::Report.new(StandardError.new("test error"))
    Telebugs::Middleware::IgnoreEnvironments.new("production", ["production"]).call(report)

    assert report.ignored
  end

  def test_ignore_environments_when_env_does_not_match
    report = Telebugs::Report.new(StandardError.new("test error"))
    Telebugs::Middleware::IgnoreEnvironments.new("development", ["production"]).call(report)

    refute report.ignored
  end

  def test_weight
    assert_equal(-1000, Telebugs::Middleware::IgnoreEnvironments.new("production", []).weight)
  end
end
