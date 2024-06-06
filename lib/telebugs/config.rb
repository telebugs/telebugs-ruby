# frozen_string_literal: true

module Telebugs
  # Represents the Telebugs config. A config contains all the options that you
  # can use to configure a +Telebugs::Notifier+ instance.
  class Config
    attr_accessor :api_key

    class << self
      attr_writer :instance

      def instance
        @instance ||= new
      end
    end

    def initialize
      @api_key = nil
    end
  end
end
