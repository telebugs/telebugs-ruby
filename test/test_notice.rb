# frozen_string_literal: true

require "test_helper"

class TestNotice < Minitest::Test
  def fixture_path(filename)
    File.expand_path(File.join("test", "fixtures", filename))
  end

  def project_root_path(filename)
    fixture_path(File.join("project_root", filename))
  end

  def setup
    Telebugs.configure do |c|
      c.root_directory = project_root_path("")
    end
  end

  def teardown
    Telebugs::Config.instance.reset
  end

  def test_to_json_with_nested_errors
    begin
      raise StandardError.new("error 1")
    rescue => _
      begin
        raise StandardError.new("error 2")
      rescue => e2
        n = Telebugs::Notice.new(e2)
      end
    end

    json = JSON.parse(n.to_json)
    error1 = json["errors"][0]
    error2 = json["errors"][1]

    assert_equal "StandardError", error1["type"]
    assert_equal "error 2", error1["message"]
    assert error1.key?("backtrace")
    assert error1["backtrace"].size > 0
    assert_nil error1["backtrace"][0]["code"]

    assert_equal "StandardError", error2["type"]
    assert_equal "error 1", error2["message"]
    assert error2.key?("backtrace")
    assert error2["backtrace"].size > 0
    assert_nil error2["backtrace"][0]["code"]
  end

  def test_to_json_code
    error = RuntimeError.new
    error.set_backtrace([
      "#{project_root_path("code.rb")}:18:in `start'",
      fixture_path("notroot.txt:3:in `pineapple'"),
      "#{project_root_path("vendor/bundle/ignored_file.rb")}:2:in `ignore_me'"
    ])

    n = Telebugs::Notice.new(error)
    json = JSON.parse(n.to_json)
    backtrace = json["errors"][0]["backtrace"]

    assert_equal 3, backtrace.size

    assert_equal(
      {
        "start_line" => 16,
        "lines" => [
          "  end",
          "",
          "  def start",
          "    loop do",
          "      print \"You: \""
        ]
      },
      backtrace[0]["code"]
    )

    assert_nil backtrace[1]["code"]
    assert_nil backtrace[2]["code"]
  end
end
