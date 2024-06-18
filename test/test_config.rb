# frozen_string_literal: true

require "test_helper"

class TestConfig < Minitest::Test
  def teardown
    Telebugs.config.reset
  end

  def test_api_key
    Telebugs.configure { |c| c.api_key = "12345:abcdef" }

    assert_equal "12345:abcdef", Telebugs.config.api_key
  end

  def test_error_api_url
    Telebugs.configure { |c| c.api_url = "example.com" }

    assert_equal URI("example.com"), Telebugs.config.api_url
  end

  def test_root_directory
    Telebugs.configure { |c| c.root_directory = "/etc" }

    assert_equal "/etc", Telebugs.config.root_directory
  end

  def test_root_directory_overwrite_root_directory_filter_middleware
    Telebugs.configure do |c|
      c.middleware.use Telebugs::Middleware::RootDirectoryFilter.new("/tmp")
      c.root_directory = "/tmp"
      c.root_directory = "/var"
      c.root_directory = "/etc"
    end

    assert_equal 2, Telebugs.config.middleware.middlewares.size
  end

  def test_middleware
    middleware_class = Class.new(Telebugs::Middleware)

    Telebugs.configure do |c|
      c.middleware.use middleware_class.new
    end

    assert_equal 3, Telebugs.config.middleware.middlewares.size
  end

  def test_default_middleware_list
    middleware_list = Telebugs.config.middleware.middlewares.map(&:class)
    assert_includes middleware_list, Telebugs::Middleware::GemRootFilter
    assert_includes middleware_list, Telebugs::Middleware::RootDirectoryFilter
  end
end
