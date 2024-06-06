# frozen_string_literal: true

require "test_helper"

class TestSender < Minitest::Test
  def test_send_attaches_correct_authorization_headers
    Telebugs.configure { |c| c.api_key = "12345:abcdef" }

    stub = stub_request(:post, Telebugs::Config.instance.api_url)
      .to_return(status: 201)

    Telebugs::Sender.new.send({"error" => "error"})

    assert_requested stub.with(
      headers: {
        "Authorization" => "Bearer 12345:abcdef",
        "Content-Type" => "application/json",
        "User-Agent" => "telebugs-ruby/#{Telebugs::VERSION} (ruby/#{RUBY_VERSION})"
      },
      body: {"error" => "error"}.to_json
    )
  end

  def test_send_raises_http_error_when_response_code_is_not_created
    Telebugs.configure { |c| c.api_key = "12345:abcdef" }

    stub_request(:post, Telebugs::Config.instance.api_url)
      .to_return(status: 500, body: {"error" => "error"}.to_json)

    assert_raises(Telebugs::HTTPError) do
      Telebugs::Sender.new.send({"error" => "error"})
    end
  end
end
