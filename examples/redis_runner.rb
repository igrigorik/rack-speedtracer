require 'rubygems'
require 'rack'

$LOAD_PATH.unshift 'lib'
$LOAD_PATH.unshift 'examples'

require 'rack/speedtracer'
require 'someapp'

builder = Rack::Builder.new do
  use Rack::CommonLogger
  use Rack::SpeedTracer, :storage => Rack::SpeedTracer::Storage::Redis

  run SomeApp.new
end

Rack::Handler::Thin.run builder.to_app, :Port => 4567