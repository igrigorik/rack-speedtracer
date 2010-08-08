require 'rack'
require 'yajl'
require 'uuid'

require 'rack/speedtracer/context'
require 'rack/speedtracer/tracer'
require 'rack/speedtracer/memory_storage'
require 'rack/speedtracer/redis_storage'

module Rack
  module SpeedTracer
    def self.new(app, options = {}, &blk)
      storage = case options.delete(:storage)
      when :redis then
        RedisStorage
      else
        MemoryStorage
      end

      Context.new(app, {:storage_class => storage}.merge(options), &blk)
    end
  end
end
