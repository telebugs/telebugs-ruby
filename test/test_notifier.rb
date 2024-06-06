# frozen_string_literal: true

require "test_helper"

class TestNotifier < Minitest::Test
  def teardown
    WebMock.reset!
  end

  def test_notify_returns_a_promise_that_resolves_to_a_hash
    stub_request(:post, Telebugs::Config.instance.api_url)
      .to_return(status: 201, body: {id: "123"}.to_json)

    p = Telebugs::Notifier.new.notify(StandardError.new)

    assert_equal({"id" => "123"}, p.value)
  end
end
