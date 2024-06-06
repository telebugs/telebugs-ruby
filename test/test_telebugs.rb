# frozen_string_literal: true

require "test_helper"

class TestTelebugs < Minitest::Test
  def teardown
    Telebugs::Config.instance.reset
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

    assert_equal key, Telebugs::Config.instance.api_key
  end

  def test_notify_returns_a_fullfilled_promise_when_request_succeeds
    stub_request(:post, Telebugs::Config.instance.api_url)
      .to_return(status: 201, body: {id: "123"}.to_json)

    p = Telebugs.notify(error: StandardError.new)
    p.wait

    assert p.fulfilled?
  end

  def test_notify_returns_a_rejected_promise_when_request_fails
    stub_request(:post, Telebugs::Config.instance.api_url).to_return(status: 500)

    p = Telebugs.notify(error: StandardError.new)
    p.wait

    assert p.rejected?
  end
end
