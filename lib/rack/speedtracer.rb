require 'rack'
require 'yajl'
require 'uuid'

require 'rack/speedtracer/context'
require 'rack/speedtracer/tracer'
require 'rack/speedtracer/memory_storage'
require 'rack/speedtracer/redis_storage'

# auto-instrument Rails 3 applications
if defined? Rails
  if Rails::Version::Major >= 3
    require 'rack/speedtracer/rails'
  end
end

module Rack
  module SpeedTracer
    def self.new(app, options = {}, &blk)
      Context.new(app, options, &blk)
    end
  end
end
