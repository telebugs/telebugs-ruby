# frozen_string_literal: true

require "test_helper"

class TestIgnoreMiddleware < Telebugs::Middleware
  def call(report)
    report.ignored = true
  end
end

class TestReporter < Minitest::Test
  def teardown
    WebMock.reset!
    Telebugs::Config.instance.reset
  end

  def test_report_returns_a_promise_that_resolves_to_a_hash
    stub = stub_request(:post, Telebugs::Config.instance.api_url)
      .to_return(status: 201, body: {id: "123"}.to_json)

    p = Telebugs::Reporter.new.report(StandardError.new)

    assert_equal({"id" => "123"}, p.value)
    assert_requested stub
  end

  def test_reporter_returns_a_promise_that_rejects_on_http_error
    stub = stub_request(:post, Telebugs::Config.instance.api_url)
      .to_return(status: 500)

    p = Telebugs::Reporter.new.report(StandardError.new)

    assert_nil p.value
    assert_instance_of(Telebugs::HTTPError, p.reason)
    assert_requested stub
  end

  def test_reporter_does_not_send_ignored_errors
    stub = stub_request(:post, Telebugs::Config.instance.api_url)
      .to_return(status: 201, body: {id: "123"}.to_json)

    Telebugs.configure do |c|
      c.middleware.use TestIgnoreMiddleware.new
    end

    p = Telebugs::Reporter.new.report(StandardError.new)
    p.wait

    refute_requested stub
  end
end
