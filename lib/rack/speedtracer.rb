require 'rack'

require 'lib/rack/speedtracer/context'
require 'lib/rack/speedtracer/tracer'

module Rack
  module SpeedTracer
    def self.new(app, options = {}, &blk)
      Context.new(app, options, &blk)
    end
  end
end