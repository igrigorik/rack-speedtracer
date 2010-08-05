require 'forwardable'
module Rack
  module SpeedTracer

    class MemoryStorage
      extend Forwardable

      def_delegators :@db_hash, :[], :[]=

      def initialize(options)
        @db_hash = {}
      end
    end
  end
end
