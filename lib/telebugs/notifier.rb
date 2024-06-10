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
    end

    def notify(error)
      Telebugs::Promise.new(error) do
        @sender.send(error)
      end
    end
  end
end
