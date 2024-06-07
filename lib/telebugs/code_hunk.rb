# frozen_string_literal: true

module Telebugs
  # Represents a small hunk of code consisting of a base line and a couple lines
  # around it
  class CodeHunk
    MAX_LINE_LEN = 200

    # How many lines should be read around the base line.
    AROUND_LINES = 2

    def self.get(file, line)
      start_line = [line - AROUND_LINES, 1].max

      lines = get_lines(file, start_line, line + AROUND_LINES)
      return { start_line: 0, lines: [] } if lines.empty?

      {
        start_line: start_line,
        lines: lines
      }
    end

    private_class_method def self.get_lines(file, start_line, end_line)
      lines = []
      return lines unless (cached_file = get_from_cache(file))

      cached_file.with_index(1) do |l, i|
        next if i < start_line
        break if i > end_line

        lines << l[0...MAX_LINE_LEN].rstrip
      end

      lines
    end

    private_class_method def self.get_from_cache(file)
      Telebugs::FileCache[file] ||= File.foreach(file)
    rescue StandardError
      nil
    end
  end
end
