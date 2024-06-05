# frozen_string_literal: true

require "test_helper"

class TestTelebugs < Minitest::Test
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
end
