# frozen_string_literal: true

module Telebugs
  # Represents a cross-Ruby backtrace from exceptions (including JRuby Java
  # exceptions). Provides information about stack frames (such as line number,
  # file and method) in convenient for Telebugs format.
  module Backtrace
    module Patterns
      # The pattern that matches standard Ruby stack frames, such as
      # ./spec/report_spec.rb:43:in `block (3 levels) in <top (required)>'
      RUBY = %r{\A
        (?<file>.+)       # Matches './spec/report_spec.rb'
        :
        (?<line>\d+)      # Matches '43'
        :in\s
        `(?<function>.*)' # Matches "`block (3 levels) in <top (required)>'"
      \z}x

      # The pattern that matches JRuby Java stack frames, such as
      # org.jruby.ast.NewlineNode.interpret(NewlineNode.java:105)
      JAVA = %r{\A
        (?<function>.+)  # Matches 'org.jruby.ast.NewlineNode.interpret'
        \(
          (?<file>
            (?:uri:classloader:/.+(?=:)) # Matches '/META-INF/jruby.home/protocol.rb'
            |
            (?:uri_3a_classloader_3a_.+(?=:)) # Matches 'uri_3a_classloader_3a_/gems/...'
            |
            [^:]+        # Matches 'NewlineNode.java'
          )
          :?
          (?<line>\d+)?  # Matches '105'
        \)
      \z}x

      # The pattern that tries to assume what a generic stack frame might look
      # like, when exception's backtrace is set manually.
      GENERIC = %r{\A
        (?:from\s)?
        (?<file>.+)              # Matches '/foo/bar/baz.ext'
        :
        (?<line>\d+)?            # Matches '43' or nothing
        (?:
          in\s`(?<function>.+)'  # Matches "in `func'"
        |
          :in\s(?<function>.+)   # Matches ":in func"
        )?                       # ... or nothing
      \z}x

      # The pattern that matches exceptions from PL/SQL such as
      # ORA-06512: at "STORE.LI_LICENSES_PACK", line 1945
      # @note This is raised by https://github.com/kubo/ruby-oci8
      OCI = /\A
        (?:
          ORA-\d{5}
          :\sat\s
          (?:"(?<function>.+)",\s)?
          line\s(?<line>\d+)
        |
          #{GENERIC}
        )
      \z/x

      # The pattern that matches CoffeeScript backtraces usually coming from
      # Rails & ExecJS
      EXECJS = /\A
        (?:
          # Matches 'compile ((execjs):6692:19)'
          (?<function>.+)\s\((?<file>.+):(?<line>\d+):\d+\)
        |
          # Matches 'bootstrap_node.js:467:3'
          (?<file>.+):(?<line>\d+):\d+(?<function>)
        |
          # Matches the Ruby part of the backtrace
          #{RUBY}
        )
      \z/x
    end

    def self.parse(error)
      return [] if error.backtrace.nil? || error.backtrace.none?

      parse_backtrace(error)
    end

    # Checks whether the given exception was generated by JRuby's VM.
    def self.java_exception?(error)
      if defined?(Java::JavaLang::Throwable) &&
          error.is_a?(Java::JavaLang::Throwable)
        return true
      end

      return false unless error.respond_to?(:backtrace)

      (Patterns::JAVA =~ error.backtrace.first) != nil
    end

    class << self
      private

      def best_regexp_for(error)
        if java_exception?(error)
          Patterns::JAVA
        elsif oci_exception?(error)
          Patterns::OCI
        elsif execjs_exception?(error)
          Patterns::EXECJS
        else
          Patterns::RUBY
        end
      end

      def oci_exception?(error)
        defined?(OCIError) && error.is_a?(OCIError)
      end

      def execjs_exception?(error)
        return false unless defined?(ExecJS::RuntimeError)
        return true if error.is_a?(ExecJS::RuntimeError)
        return true if error.cause&.is_a?(ExecJS::RuntimeError)

        false
      end

      def stack_frame(regexp, stackframe)
        if (match = match_frame(regexp, stackframe))
          return {
            file: match[:file],
            line: (Integer(match[:line]) if match[:line]),
            function: match[:function]
          }
        end

        {file: nil, line: nil, function: stackframe}
      end

      def match_frame(regexp, stackframe)
        match = regexp.match(stackframe)
        return match if match

        Patterns::GENERIC.match(stackframe)
      end

      def parse_backtrace(error)
        regexp = best_regexp_for(error)

        error.backtrace.map.with_index do |stackframe, i|
          frame = stack_frame(regexp, stackframe)
          next(frame) unless frame[:file]

          frame
        end
      end
    end
  end
end
