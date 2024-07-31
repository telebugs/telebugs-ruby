# frozen_string_literal: true

module Telebugs
  class Middleware
    class IgnoreEnvironments < Telebugs::BaseMiddleware
      def initialize(current_env, ignore_envs)
        @current_env = current_env
        @ignore_envs = ignore_envs
      end

      def call(report)
        report.ignored = @ignore_envs.include?(@current_env)
      end

      def weight
        -1000
      end
    end
  end
end
