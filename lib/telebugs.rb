# frozen_string_literal: true

require "concurrent"
require "net/https"
require "json"

require_relative "telebugs/version"
require_relative "telebugs/config"
require_relative "telebugs/promise"
require_relative "telebugs/notifier"
require_relative "telebugs/sender"
require_relative "telebugs/wrapped_error"
require_relative "telebugs/report"
require_relative "telebugs/error_message"
require_relative "telebugs/backtrace"
require_relative "telebugs/file_cache"
require_relative "telebugs/code_hunk"
require_relative "telebugs/middleware"
require_relative "telebugs/middleware_stack"
require_relative "telebugs/truncator"

module Telebugs
  # The general error that this library uses when it wants to raise.
  Error = Class.new(StandardError)

  HTTPError = Class.new(Error)

  class << self
    def configure
      yield Config.instance
    end

    def notify(error:)
      Notifier.instance.notify(error)
    end
  end
end
