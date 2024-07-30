# frozen_string_literal: true

module Telebugs
  class Config
    ERROR_API_URL = "https://api.telebugs.com/2024-03-28/errors"

    attr_accessor :api_key,
      :middleware

    attr_reader :api_url,
      :root_directory,
      :ignore_environments,
      :environment

    class << self
      attr_writer :instance

      def instance
        @instance ||= new
      end
    end

    def initialize
      reset
    end

    def reset
      self.api_key = nil
      self.api_url = ERROR_API_URL

      @middleware = MiddlewareStack.new
      @middleware.use Middleware::GemRootFilter.new

      self.root_directory = (defined?(Bundler) && Bundler.root) || Dir.pwd
      self.environment = ""
      self.ignore_environments = []
    end

    def api_url=(url)
      @api_url = URI(url)
    end

    def root_directory=(directory)
      @root_directory = File.realpath(directory)

      @middleware.delete(Middleware::RootDirectoryFilter)
      @middleware.use Middleware::RootDirectoryFilter.new(@root_directory)
    end

    def environment=(environment)
      @environment = environment

      @middleware.delete(Middleware::IgnoreEnvironments)
      @middleware.use Middleware::IgnoreEnvironments.new(@environment, @ignore_environments)
    end

    def ignore_environments=(ignore_environments)
      @ignore_environments = ignore_environments

      @middleware.delete(Middleware::IgnoreEnvironments)
      @middleware.use Middleware::IgnoreEnvironments.new(@environment, @ignore_environments)
    end
  end
end
