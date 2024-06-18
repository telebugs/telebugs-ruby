# frozen_string_literal: true

module Telebugs
  class Middleware
    # GemRootFilter is a middleware that filters out the root path of the gems.
    # It replaces the root path with the gem name and version.
    class GemRootFilter < Telebugs::Middleware
      def initialize
        @gem_paths = Gem.path.map { |path| /\A#{Regexp.escape(path)}\/gems\// }
      end

      def call(report)
        report.data[:errors].each do |error|
          process_backtrace(error[:backtrace])
        end
      end

      def weight
        -999
      end

      private

      def process_backtrace(backtrace)
        backtrace.each do |frame|
          next unless (file = frame[:file])

          process_frame(frame, file)
        end
      end

      def process_frame(frame, file)
        @gem_paths.each do |gem_path_regex|
          next unless file&.match?(gem_path_regex)

          frame[:file] = format_file(file.sub(gem_path_regex, ""))
          break
        end
      end

      def format_file(file)
        parts = file.split("/")

        gem_info = parts[0].split("-")
        if gem_info.size < 2
          gem_name = gem_info[0]
          gem_version = gem_info[1]
        else
          gem_name = gem_info[0..-2].join("-")
          gem_version = gem_info[-1]
        end

        file_path = parts[1..].join("/")

        "#{gem_name} (#{gem_version}) #{file_path}"
      end
    end
  end
end
