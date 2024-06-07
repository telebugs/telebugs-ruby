# frozen_string_literal: true

module Telebugs
  module FileCache
    MAX_SIZE = 50
    MUTEX = Mutex.new

    # Associates the value given by +value+ with the key given by +key+. Deletes
    # entries that exceed +MAX_SIZE+.
    def self.[]=(key, value)
      MUTEX.synchronize do
        data[key] = value
        data.delete(data.keys.first) if data.size > MAX_SIZE
      end
    end

    # Retrieve an object from the cache.
    def self.[](key)
      MUTEX.synchronize do
        data[key]
      end
    end

    # Checks whether the cache is empty. Needed only for the test suite.
    def self.empty?
      MUTEX.synchronize do
        data.empty?
      end
    end

    def self.reset
      MUTEX.synchronize do
        @data = {}
      end
    end

    private_class_method def self.data
      @data ||= {}
    end
  end
end
