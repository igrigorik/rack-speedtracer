require 'spec_helper'
require 'rack/speedtracer/redis_storage'

describe Rack::SpeedTracer::RedisStorage do
  before(:each) do
    @mock_redis = mock('redis')
    Redis.stub(:new).and_return(@mock_redis)
    @storage_klass = Rack::SpeedTracer::RedisStorage
  end

  it "fetches traces from Redis" do
    r = @storage_klass.new({})
    @mock_redis.should_receive(:get).with("speedtracer:some_trace")
    trace = r['some_trace']
  end

  it "saves traces in Redis with a default expiry time" do
    r = @storage_klass.new({})
    @mock_redis.should_receive(:set).with("speedtracer:some_trace", "trace_contents")
    @mock_redis.should_receive(:expire).with("speedtracer:some_trace", 600)
    r['some_trace'] = "trace_contents"
  end
end
