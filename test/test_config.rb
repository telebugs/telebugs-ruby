# frozen_string_literal: true

require "test_helper"

class TestConfig < Minitest::Test
  def test_api_key
    Telebugs.configure { |c| c.api_key = "12345:abcdef" }

    assert_equal "12345:abcdef", Telebugs::Config.instance.api_key
  end

  def test_error_api_url
    Telebugs.configure { |c| c.api_url = "example.com" }

    assert_equal URI("example.com"), Telebugs::Config.instance.api_url
  end
end
