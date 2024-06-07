# frozen_string_literal: true

require "test_helper"

class TestErrorMessage < Minitest::Test
  def test_parse_when_error_message_is_nil
    error = Class.new(StandardError) {
      def message
      end
    }.new

    assert_nil Telebugs::ErrorMessage.parse(error)
  end

  def test_parse_with_error_highlighting_in_messages
    begin
      raise "undefined method `[]' for nil:NilClass\n\n    " \
            "data[:result].first[:first_name]\n                       ^^^^^^^^^^^^^"
    rescue => e
    end

    error_message = Telebugs::ErrorMessage.parse(e)
    assert_equal "undefined method `[]' for nil:NilClass", error_message
  end

  def test_parse_when_error_message_contains_invalid_characters
    begin
      JSON.parse(Marshal.dump(Time.now))
    rescue JSON::ParserError => e
    end

    error_message = Telebugs::ErrorMessage.parse(e)
    assert_match(/unexpected token at/, error_message)
  end
end
