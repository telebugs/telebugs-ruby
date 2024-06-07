# frozen_string_literal: true

require "test_helper"

class TestNotice < Minitest::Test
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

    assert_equal "StandardError", error2["type"]
    assert_equal "error 1", error2["message"]
    assert error2.key?("backtrace")
    assert error2["backtrace"].size > 0
  end
end
