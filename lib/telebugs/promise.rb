# frozen_string_literal: true

module Telebugs
  # Wraps Concurrent::Promise to provide a consistent API for promises that we
  # can control.
  class Promise
    def initialize(...)
      @future = Concurrent::Promises.future(...)
    end

    def value
      @future.value
    end
  end
end
