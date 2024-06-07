# frozen_string_literal: true

module Telebugs
  # Represents a piece of information that will be sent to Telebugs API to
  # report an error.
  class Notice
    # The list of possible exceptions that might be raised when an object is
    # converted to JSON
    JSON_EXCEPTIONS = [
      IOError,
      NotImplementedError,
      JSON::GeneratorError,
      Encoding::UndefinedConversionError
    ].freeze

    # The maxium size of the JSON payload in bytes
    MAX_NOTICE_SIZE = 64000

    def initialize(error)
      @payload = {
        errors: errors_as_json(error)
      }
    end

    # Converts the notice to JSON. Calls +to_json+ on each object inside
    # notice's payload. Truncates notices, JSON representation of which is
    # bigger than {MAX_NOTICE_SIZE}.
    def to_json(*_args)
      loop do
        begin
          json = @payload.to_json
        rescue *JSON_EXCEPTIONS
          # TODO
        else
          return json if json && json.bytesize <= MAX_NOTICE_SIZE
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
          backtrace: Backtrace.parse(e)
        }
      end
    end

    def truncate
      0
    end
  end
end
