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

    assert_equal(
      {
        "errors" => [
          {
            "type" => "StandardError",
            "message" => "error 2"
          },
          {
            "type" => "StandardError",
            "message" => "error 1"
          }
        ]
      },
      JSON.parse(n.to_json)
    )
  end

  def test_to_json_with_error_highlighting_in_messages
    begin
      raise "undefined method `[]' for nil:NilClass\n\n    " \
            "data[:result].first[:first_name]\n                       ^^^^^^^^^^^^^"
    rescue => e
    end

    n = Telebugs::Notice.new(e)

    assert_equal(
      {
        "errors" => [
          {
            "type" => "RuntimeError",
            "message" => "undefined method `[]' for nil:NilClass"
          }
        ]
      },
      JSON.parse(n.to_json)
    )
  end

  def test_to_json_when_error_message_contains_invalid_characters
    begin
      JSON.parse(Marshal.dump(Time.now))
    rescue JSON::ParserError => e
    end

    n = Telebugs::Notice.new(e)
    json = JSON.parse(n.to_json)

    assert_equal "JSON::ParserError", json["errors"].first["type"]
    assert_match(/unexpected token at/, json["errors"].first["message"])
  end

  def test_to_json_when_error_message_is_nil
    error = Class.new(StandardError) {
      def message
      end
    }.new

    n = Telebugs::Notice.new(error)

    assert_equal(
      {
        "errors" => [
          {
            "type" => nil,
            "message" => nil
          }
        ]
      },
      JSON.parse(n.to_json)
    )
  end
end
