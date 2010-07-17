require 'rubygems'
require 'rack'

require 'lib/rack/speedtracer'

class SomeApp
  def call(env)
    env['st.tracer'].run('computation: 5**100000') do
      env['st.tracer'].run('computation 2: 5**10000') do
        5**10000
      end

      5**100000
    end

    env['st.tracer'].run('sleep(0.5)') do
      sleep(0.5)
    end

    [200, {"Content-Type" => "text/plain"}, "Hello World"]
  end
end

builder = Rack::Builder.new do
  use Rack::CommonLogger
  use Rack::SpeedTracer

  run SomeApp.new
end

Rack::Handler::Thin.run builder.to_app, :Port => 4567