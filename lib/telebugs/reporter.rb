# frozen_string_literal: true

module Telebugs
  # Reporter is reponsible for sending reports to Telebugs.
  class Reporter
    class << self
      attr_writer :instance

      def instance
        @instance ||= new
      end
    end

    def initialize
      @sender = Sender.new
      @config = Config.instance
    end

    def report(error)
      Telebugs::Promise.new(error) do
        report = Report.new(error)

        @config.middleware.call(report)
        next if report.ignored

        @sender.send(report)
      end
    end
  end
end
