# frozen_string_literal: true

require "test_helper"

class TestWrappedError < Minitest::Test
  def test_unwraps_errors_without_a_cause
    error = StandardError.new
    wrapped = Telebugs::WrappedError.new(error)

    assert_equal [error], wrapped.unwrap
  end

  def test_unwraps_no_more_than_3_nested_errors
    begin
      raise "error 1"
    rescue => _
      begin
        raise "error 2"
      rescue => _
        begin
          raise "error 3"
        rescue => e3
          begin
            raise "error 4"
          rescue => e4
            begin
              raise "error 5"
            rescue => e5
            end
          end
        end
      end
    end

    wrapped = Telebugs::WrappedError.new(e5)
    unwrapped = wrapped.unwrap

    assert_equal 3, unwrapped.size
    assert_equal [e5, e4, e3], unwrapped
  end
end
