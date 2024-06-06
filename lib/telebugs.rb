# frozen_string_literal: true

require "concurrent"

require_relative "telebugs/version"
require_relative "telebugs/config"
require_relative "telebugs/promise"

module Telebugs
  # The general error that this library uses when it wants to raise.
  Error = Class.new(StandardError)

  class << self
    def configure
      yield Telebugs::Config.instance
    end

    def notify(error:)
      Telebugs::Promise.new(error) do
      end
    end
  end
end
