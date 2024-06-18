# frozen_string_literal: true

require "test_helper"

class TestRootDirectoryFilter < Minitest::Test
  def test_root_directory_filter
    root_directory = "/tmp"
    Telebugs.configure do |c|
      c.root_directory = root_directory
    end

    e = StandardError.new("test error")
    e.set_backtrace([
      "#{root_directory}/app/models/user.rb:1:in `save'"
    ])

    report = Telebugs::Report.new(e)
    Telebugs::Middleware::RootDirectoryFilter.new(root_directory).call(report)

    assert_equal "app/models/user.rb", report.data[:errors][0][:backtrace][0][:file]
  end
end
