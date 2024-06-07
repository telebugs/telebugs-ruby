# frozen_string_literal: true

module Telebugs
  # Parses error messages to make them more consistent.
  module ErrorMessage
    # On Ruby 3.1+, the error highlighting gem can produce messages that can
    # span over multiple lines. We don't want to display multiline error titles.
    # Therefore, we want to strip out the higlighting part so that the errors
    # look consistent.
    RUBY_31_ERROR_HIGHLIGHTING_DIVIDER = "\n\n"

    # The options for +String#encode+
    ENCODING_OPTIONS = {invalid: :replace, undef: :replace}.freeze

    def self.parse(error)
      return unless (msg = error.message)

      msg.encode(Encoding::UTF_8, **ENCODING_OPTIONS)
        .split(RUBY_31_ERROR_HIGHLIGHTING_DIVIDER)
        .first
    end
  end
end
