require 'rack'

require 'rack/speedtracer/context'
require 'rack/speedtracer/tracer'

module Rack
  module SpeedTracer
    def self.new(app, options = {}, &blk)
      Context.new(app, options, &blk)
    end
  end
end