# frozen_string_literal: true

module Telebugs
  class Middleware
    # Filters out the root directory from the backtrace paths.
    class RootDirectoryFilter < Telebugs::Middleware
      def initialize(root_directory)
        @root_directory = root_directory
      end

      def call(report)
        report.data[:errors].each do |error|
          error[:backtrace].each do |frame|
            next unless (file = frame[:file])
            next unless file.start_with?(@root_directory)

            file.sub!(/#{@root_directory}\/?/, "")
          end
        end
      end

      def weight
        -999
      end
    end
  end
end
