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

    # The maximum size of hashes, arrays and strings in the report.
    DATA_MAX_SIZE = 10000

    REPORTER = {
      library: {name: "telebugs", version: Telebugs::VERSION}.freeze,
      platform: {name: "Ruby", version: RUBY_VERSION}.freeze
    }.freeze

    attr_reader :data
    attr_accessor :ignored

    def initialize(error)
      @ignored = false
      @truncator = Truncator.new(DATA_MAX_SIZE)

      @data = {
        errors: errors_as_json(error),
        reporters: [REPORTER]
      }
    end

    # Converts the report to JSON. Calls +to_json+ on each object inside the
    # reports' data. Truncates report data, JSON representation of which is
    # bigger than {MAX_REPORT_SIZE}.
    def to_json(*_args)
      loop do
        begin
          json = @data.to_json
        rescue *JSON_EXCEPTIONS
          # TODO: log the error
        else
          return json if json && json.bytesize <= MAX_REPORT_SIZE
        end

        break if truncate == 0
      end
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

    def attach_code(backtrace)
      backtrace.each do |frame|
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
      @data.each_key do |key|
        @data[key] = @truncator.truncate(@data[key])
      end

      @truncator.reduce_max_size
    end
  end
end
