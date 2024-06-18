# frozen_string_literal: true

module Telebugs
  class Config
    ERROR_API_URL = "https://api.telebugs.com/2024-03-28/errors"

    attr_accessor :api_key,
      :middleware

    attr_reader :api_url,
      :root_directory

    class << self
      attr_writer :instance

      def instance
        @instance ||= new
      end
    end

    def initialize
      reset
    end

    def api_url=(url)
      @api_url = URI(url)
    end

    def root_directory=(directory)
      @root_directory = File.realpath(directory)

      if @middleware
        @middleware.delete(Middleware::RootDirectoryFilter)
        @middleware.use Middleware::RootDirectoryFilter.new(@root_directory)
      end
    end

    def reset
      self.api_key = nil
      self.api_url = ERROR_API_URL
      self.root_directory = File.realpath(
        (defined?(Bundler) && Bundler.root) ||
        Dir.pwd
      )

      @middleware = MiddlewareStack.new
      @middleware.use Middleware::GemRootFilter.new
      @middleware.use Middleware::RootDirectoryFilter.new(root_directory)
    end
  end
end
