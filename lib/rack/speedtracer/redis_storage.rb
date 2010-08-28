require 'redis'

module Rack
  module SpeedTracer
    module Storage

      class Redis
        def initialize(options)
          @redis = ::Redis.new(options[:redis_options] || {})
          @ttl = options[:trace_ttl] || 600
          @namespace = options[:namespace] || "speedtracer"
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
            "#{@namespace}:#{key}"
          end
      end
    end
  end
end
