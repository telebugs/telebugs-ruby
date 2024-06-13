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

    def reason
      @future.reason
    end

    def wait
      @future.wait
    end

    def fulfilled?
      @future.fulfilled?
    end

    def rejected?
      @future.rejected?
    end

    def then(...)
      @future.then(...)
    end
  end
end
