# frozen_string_literal: true

require "test_helper"

class TestFileCache < Minitest::Test
  def teardown
    Telebugs::FileCache.reset
  end

  def test_set_when_cache_limit_is_not_reached
    max_size = Telebugs::FileCache::MAX_SIZE
    max_size.times do |i|
      Telebugs::FileCache["key#{i}"] = "value#{i}"
    end

    assert_equal "value0", Telebugs::FileCache["key0"]
    assert_equal "value#{max_size - 1}", Telebugs::FileCache["key#{max_size - 1}"]
  end

  def test_set_when_cache_over_limit
    max_size = 2 * Telebugs::FileCache::MAX_SIZE
    max_size.times do |i|
      Telebugs::FileCache["key#{i}"] = "value#{i}"
    end

    assert_nil Telebugs::FileCache["key49"]
    assert_equal "value50", Telebugs::FileCache["key50"]
    assert_equal "value#{max_size - 1}", Telebugs::FileCache["key#{max_size - 1}"]
  end
end
