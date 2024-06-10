# frozen_string_literal: true

require "test_helper"

class TelebugsTruncatorTest < Minitest::Test
  def multiply_by_2_max_len(chr, max_len)
    chr * 2 * max_len
  end

  def setup
    @max_size = 3
    @truncated = "[Truncated]"
    @max_len = @max_size + @truncated.length
  end

  def test_truncate_frozen_string
    object = multiply_by_2_max_len("a", @max_size)
    truncator = Telebugs::Truncator.new(@max_size).truncate(object)

    assert_equal @max_len, truncator.length
    assert truncator.frozen?
  end

  def test_truncate_frozen_hash_of_strings
    object = {
      banana: multiply_by_2_max_len("a", @max_size),
      kiwi: multiply_by_2_max_len("b", @max_size),
      strawberry: "c",
      shrimp: "d"
    }.freeze

    truncator = Telebugs::Truncator.new(@max_size).truncate(object)

    assert_equal @max_size, truncator.size
    assert truncator.frozen?
    assert_equal({banana: "aaa[Truncated]", kiwi: "bbb[Truncated]", strawberry: "c"}, truncator)
    assert truncator[:banana].frozen?
    assert truncator[:kiwi].frozen?
    assert truncator[:strawberry].frozen?
  end

  def test_truncate_frozen_array_of_strings
    object = [
      multiply_by_2_max_len("a", @max_size),
      "b",
      multiply_by_2_max_len("c", @max_size),
      "d"
    ].freeze

    truncator = Telebugs::Truncator.new(@max_size).truncate(object)

    assert_equal @max_size, truncator.size
    assert truncator.frozen?
    assert_equal ["aaa[Truncated]", "b", "ccc[Truncated]"], truncator
    assert truncator[0].frozen?
    assert truncator[1].frozen?
    assert truncator[2].frozen?
  end

  def test_truncate_frozen_set_of_strings
    object = Set.new([
      multiply_by_2_max_len("a", @max_size),
      "b",
      multiply_by_2_max_len("c", @max_size),
      "d"
    ]).freeze

    truncator = Telebugs::Truncator.new(@max_size).truncate(object)

    assert_equal @max_size, truncator.size
    assert truncator.frozen?
    assert_equal Set.new(["aaa[Truncated]", "b", "ccc[Truncated]"]), truncator
  end

  def test_truncate_frozen_object_with_to_json
    object = Object.new
    def object.to_json
      '{"object":"shrimp"}'
    end
    object.freeze

    truncator = Telebugs::Truncator.new(@max_size).truncate(object)

    assert_equal @max_len, truncator.length
    assert truncator.frozen?
    assert_equal '{"o[Truncated]', truncator
  end

  def test_truncate_object_without_to_json
    object = Object.new
    def object.to_json
      raise Telebugs::Report::JSON_EXCEPTIONS.first
    end

    truncator = Telebugs::Truncator.new(@max_size).truncate(object)

    assert_equal @max_len, truncator.length
    assert_equal "#<O[Truncated]", truncator
  end

  def test_self_returning_objects
    [1, true, false, :symbol].each do |object|
      assert_equal object, Telebugs::Truncator.new(@max_size).truncate(object)
    end

    assert_nil Telebugs::Truncator.new(@max_size).truncate(nil)
  end

  def test_recursive_array
    a = %w[aaaaa bb]
    a << a
    a << "c"

    truncator = Telebugs::Truncator.new(@max_size).truncate(a)

    assert_equal ["aaa[Truncated]", "bb", "[Circular]"], truncator
  end

  def test_recursive_array_with_recursive_hashes
    a = []
    a << a

    h = {}
    h[:k] = h
    a << h << "aaaa"

    truncator = Telebugs::Truncator.new(@max_size).truncate(a)

    assert_equal ["[Circular]", {k: "[Circular]"}, "aaa[Truncated]"], truncator
    assert truncator.frozen?
  end

  def test_recursive_set_with_recursive_arrays
    s = Set.new
    s << s

    h = {}
    h[:k] = h
    s << h << "aaaa"

    truncator = Telebugs::Truncator.new(@max_size).truncate(s)

    assert_equal Set.new(["[Circular]", {k: "[Circular]"}, "aaa[Truncated]"]), truncator
    assert truncator.frozen?
  end

  def test_hash_with_long_strings
    object = {
      a: multiply_by_2_max_len("a", @max_size),
      b: multiply_by_2_max_len("b", @max_size),
      c: {d: multiply_by_2_max_len("d", @max_size), e: "e"}
    }

    truncator = Telebugs::Truncator.new(@max_size).truncate(object)

    assert_equal(
      {a: "aaa[Truncated]", b: "bbb[Truncated]", c: {d: "ddd[Truncated]", e: "e"}},
      truncator
    )
    assert truncator.frozen?
  end

  def test_string_with_valid_unicode_characters
    object = "€€€€€"
    truncator = Telebugs::Truncator.new(@max_size).truncate(object)

    assert_equal "€€€[Truncated]", truncator
  end

  def test_ascii_8bit_string_with_invalid_characters
    encoded = Base64.encode64("\xD3\xE6\xBC\x9D\xBA").encode!("ASCII-8BIT")
    object = Base64.decode64(encoded).freeze

    truncator = Telebugs::Truncator.new(@max_size).truncate(object)

    assert_equal "���[Truncated]", truncator
    assert truncator.frozen?
  end

  def test_array_with_hashes_and_hash_like_objects_with_identical_keys
    hashie = Class.new(Hash)

    object = {
      errors: [
        {file: "a"},
        {file: "a"},
        hashie.new.merge(file: "bcde")
      ]
    }

    truncator = Telebugs::Truncator.new(@max_size).truncate(object)

    assert_equal(
      {errors: [{file: "a"}, {file: "a"}, hashie.new.merge(file: "bcd[Truncated]")]},
      truncator
    )
    assert truncator.frozen?
  end
end
