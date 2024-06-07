# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "telebugs"

require "minitest/autorun"
require "webmock/minitest"

class OCIError < StandardError; end

module ExecJS; end

class ExecJS::RuntimeError < StandardError; end
