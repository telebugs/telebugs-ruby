# frozen_string_literal: true

require_relative "telebugs/version"
require_relative "telebugs/config"

module Telebugs
  # The general error that this library uses when it wants to raise.
  Error = Class.new(StandardError)

  class << self
    def configure
      yield Telebugs::Config.instance
    end

    def notify(error:)
      Concurrent::Promises.future do
      end
    end
  end
end
