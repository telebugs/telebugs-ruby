# frozen_string_literal: true

module Telebugs
  # Represents a middleware that can be used to filter out errors.
  # You must inherit from this class and implement the #call method.
  class BaseMiddleware
    DEFAULT_WEIGHT = 0

    def weight
      DEFAULT_WEIGHT
    end

    def call(_report)
      raise NotImplementedError, "You must implement the #call method"
    end
  end
end
