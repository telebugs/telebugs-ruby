# frozen_string_literal: true

require "test_helper"

class TestTelebugs < Minitest::Test
  def teardown
    Telebugs.config.reset
    WebMock.reset!
  end

  def test_that_it_has_a_version_number
    refute_nil ::Telebugs::VERSION
  end

  def test_configure_configures_project_key
    key = "12345:abcdef"

    Telebugs.configure do |config|
      config.api_key = key
    end

    assert_equal key, Telebugs.config.api_key
  end

  def test_report_returns_a_fullfilled_promise_when_request_succeeds
    stub = stub_request(:post, Telebugs.config.api_url)
      .to_return(status: 201, body: {id: "123"}.to_json)

    p = Telebugs.report(StandardError.new)
    p.wait

    assert p.fulfilled?
    assert_requested stub
  end

  def test_report_returns_a_rejected_promise_when_request_fails
    stub = stub_request(:post, Telebugs.config.api_url)
      .to_return(status: 500, body: '{"error": "Internal Server Error"}')

    p = Telebugs.report(StandardError.new)
    p.wait

    assert p.rejected?
    assert_requested stub
  end

  def test_config_exposes_the_default_config
    assert_match(/telebugs\.com/, Telebugs.config.api_url.to_s)
  end

  def test_does_not_report_errors_ignored_by_environment
    stub = stub_request(:post, Telebugs.config.api_url)
      .to_return(status: 201, body: {id: "123"}.to_json)

    Telebugs.configure do |config|
      config.environment = "test"
      config.ignore_environments = %w[test]
    end

    p = Telebugs.report(StandardError.new)
    p.wait

    assert p.fulfilled?
    refute_requested stub
  end
end
