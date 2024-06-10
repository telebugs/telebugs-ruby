# frozen_string_literal: true

module Telebugs
  # MiddlewareStack represents an ordered array of middleware.
  #
  # A middleware is an object that responds to <b>#call</b> (typically a Proc or a
  # class that implements the call method). The <b>#call</b> method must accept
  # exactly one argument: the report object.
  #
  # When you add a new middleware to the stack, it gets inserted according to its
  # <b>weight</b>. Smaller weight means the middleware will be somewhere in the
  # beginning of the array. Larger - in the end.
  class MiddlewareStack
    attr_reader :middlewares

    def initialize
      @middlewares = []
    end

    def use(new_middleware)
      @middlewares = (@middlewares << new_middleware).sort_by(&:weight).reverse
    end

    def call(report)
      @middlewares.each do |middleware|
        middleware.call(report)
      end
    end
  end
end
