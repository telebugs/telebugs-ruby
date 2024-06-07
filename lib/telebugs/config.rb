# frozen_string_literal: true

module Telebugs
  # Represents the Telebugs config. A config contains all the options that you
  # can use to configure a +Telebugs::Notifier+ instance.
  class Config
    ERROR_API_URL = "https://api.telebugs.com/2024-03-28/errors"

    attr_accessor :api_key,
                  :root_directory

    attr_reader :api_url

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

    def reset
      self.api_key = nil
      self.api_url = ERROR_API_URL
      self.root_directory = File.realpath(
        (defined?(Bundler) && Bundler.root) ||
        Dir.pwd,
      )
    end
  end
end
