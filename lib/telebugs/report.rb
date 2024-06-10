# frozen_string_literal: true

module Telebugs
  # Represents a piece of information that will be sent to Telebugs API to
  # report an error.
  class Report
    # The list of possible exceptions that might be raised when an object is
    # converted to JSON
    JSON_EXCEPTIONS = [
      IOError,
      NotImplementedError,
      JSON::GeneratorError,
      Encoding::UndefinedConversionError
    ].freeze

    # The maxium size of the JSON data in bytes
    MAX_REPORT_SIZE = 64000

    attr_reader :data
    attr_accessor :ignored

    def initialize(error)
      @ignored = false
      @data = {
        errors: errors_as_json(error)
      }
    end

    private

    def errors_as_json(error)
      WrappedError.new(error).unwrap.map do |e|
        {
          type: e.class.name,
          message: ErrorMessage.parse(e),
          backtrace: attach_code(Backtrace.parse(e))
        }
      end
    end

    def attach_code(b)
      b.each do |frame|
        next unless frame[:file]
        next unless File.exist?(frame[:file])
        next unless frame[:line]
        next unless frame_belogns_to_root_directory?(frame)
        next if %r{vendor/bundle}.match?(frame[:file])

        frame[:code] = CodeHunk.get(frame[:file], frame[:line])
      end
    end

    def frame_belogns_to_root_directory?(frame)
      frame[:file].start_with?(Telebugs::Config.instance.root_directory)
    end

    def truncate
      0
    end
  end
end
