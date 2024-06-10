# frozen_string_literal: true

module Telebugs
  # Notifier is reponsible for sending reports to Telebugs.
  class Notifier
    class << self
      attr_writer :instance

      def instance
        @instance ||= new
      end
    end

    def initialize
      @sender = Sender.new
      @middleware = Config.instance.middleware
    end

    def notify(error)
      Telebugs::Promise.new(error) do
        report = Report.new(error)

        @middleware.call(report)
        next if report.ignored

        @sender.send(report)
      end
    end
  end
end
