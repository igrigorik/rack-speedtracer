require 'redis'

module Rack
  module SpeedTracer

    class RedisStorage
      def initialize(options)
        @redis = Redis.new(options[:redis_options] || {})
        @ttl = options[:trace_ttl] || 600
      end

      def [](trace_id)
        @redis.get(namespace_key(trace_id))
      end

      def []=(trace_id, trace)
        key = namespace_key(trace_id)
        @redis.set(key, trace)
        @redis.expire(key, @ttl)
      end

      private

      def namespace_key(key)
        "speedtracer:#{key}"
      end
    end
  end
end