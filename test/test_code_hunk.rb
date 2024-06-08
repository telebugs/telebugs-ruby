# frozen_string_literal: true

require "test_helper"

class TestCodeHunk < Minitest::Test
  def test_get_when_file_is_empty
    hunk = Telebugs::CodeHunk.get("test/fixtures/project_root/empty_file.rb", 1)

    assert_equal({start_line: 0, lines: []}, hunk)
  end

  def test_get_when_file_has_one_line
    hunk = Telebugs::CodeHunk.get("test/fixtures/project_root/one_line.rb", 1)

    assert_equal(
      {
        start_line: 1,
        lines: ["Boom.new.call"]
      },
      hunk
    )
  end

  def test_get
    hunk = Telebugs::CodeHunk.get("test/fixtures/project_root/code.rb", 18)

    assert_equal(
      {
        start_line: 16,
        lines: [
          "  end",
          "",
          "  def start",
          "    loop do",
          "      print \"You: \""
        ]
      },
      hunk
    )
  end

  def test_get_with_edge_case_first_line
    hunk = Telebugs::CodeHunk.get("test/fixtures/project_root/code.rb", 1)

    assert_equal(
      {
        start_line: 1,
        lines: [
          "# frozen_string_literal: true",
          "",
          "class Botley"
        ]
      },
      hunk
    )
  end

  def test_get_with_edge_case_last_line
    hunk = Telebugs::CodeHunk.get("test/fixtures/project_root/code.rb", 39)

    assert_equal(
      {
        start_line: 37,
        lines: [
          "",
          "# Start the conversation with Botley",
          "Botley.new.start"
        ]
      },
      hunk
    )
  end

  def test_get_when_code_line_is_too_long
    hunk = Telebugs::CodeHunk.get("test/fixtures/project_root/long_line.rb", 1)

    assert_equal(
      {
        start_line: 1,
        lines: [
          "loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong"
        ]
      },
      hunk
    )
  end
end
