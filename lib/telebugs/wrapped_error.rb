# frozen_string_literal: true

module Telebugs
  # WrappedError unwraps an error and its causes up to a certain depth.
  class WrappedError
    MAX_NESTED_ERRORS = 3

    def initialize(error)
      @error = error
    end

    def unwrap
      error_list = []
      error = @error

      while error && error_list.size < MAX_NESTED_ERRORS
        error_list << error
        error = error.cause
      end

      error_list
    end
  end
end
