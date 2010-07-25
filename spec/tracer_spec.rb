require 'spec_helper'

describe Rack::SpeedTracer::Tracer do

  it 'should accept unique id, method, uri on initialize' do
    lambda { Rack::SpeedTracer::Tracer.new(1, 'GET', '/') }.should_not raise_error
  end

  describe 'response' do
    let(:tracer) { Rack::SpeedTracer::Tracer.new(1, 'GET', '/test') }

    it 'should serialize to json on finish' do
      lambda { Yajl::Parser.parse(tracer.finish) }.should_not raise_error
    end

    it 'should conform to base speedtracer JSON schema' do
      trace = Yajl::Parser.parse(tracer.finish)['trace']

      # Example base trace:
      # {"date"=>1279403357,
      #  "application"=>"Rack SpeedTracer",
      #  "id"=>1,
      #  "range"=>{"duration"=>0, "end"=>"1279403357651", "start"=>"1279403357651"},
      #  "frameStack"=>
      #   {"id"=>"0",
      #    "range"=>{"duration"=>0, "end"=>"1279403357651", "start"=>"1279403357651"},
      #    "operation"=>{"label"=>"GET /test", "type"=>"HTTP"},
      #    "children"=>[]}}

      trace.should include 'date'
      trace.should include 'application'
      trace.should include 'id'

      trace.should include 'range'
      trace['range'].should be_an_instance_of Hash

      trace.should include 'frameStack'
      trace['frameStack'].should be_an_instance_of Hash

      # root node description
      root = trace['frameStack']
      root.should include 'id'
      root['id'].to_i.should == 0

      root.should include 'range'
      root['range'].should be_an_instance_of Hash

      root.should include 'operation'
      root['operation'].should be_an_instance_of Hash
      root['operation']['label'].should match('GET /test')
      root['operation']['type'].should match('HTTP')

      root.should include 'children'
      root['children'].should be_an_instance_of Array
    end
  end

  describe 'code tracing' do
    let(:tracer) { Rack::SpeedTracer::Tracer.new(1, 'GET', '/test') }

    it 'should provide a mechanism to trace a code block' do
      lambda { tracer.run { sleep(0.01) }}.should_not raise_error
    end

    it 'should measure execution time in milliseconds' do
      tracer.run { sleep(0.01) }
      trace = Yajl::Parser.parse(tracer.finish)['trace']

      trace['range']['duration'].to_i.should == 10
    end

    it 'should return the value of the block' do
      value = Time.now
      tracer.run { value }.should == value
    end

    it 'should report traced codeblocks' do
      tracer.run { sleep(0.01) }
      trace = Yajl::Parser.parse(tracer.finish)['trace']

      trace['frameStack']['children'].size.should == 1

      child = trace['frameStack']['children'].first
      child['id'].to_i.should == 1
      child.should include 'operation'
      child['operation'].should include 'label'
      child.should include 'children'
    end

    it 'should accept optional label for each trace' do
      tracer.run('label') { sleep(0.01) }
      trace = Yajl::Parser.parse(tracer.finish)['trace']

      trace['frameStack']['children'].first['operation']['label'].should match('label')
    end

    it 'should produce nested traces' do
      tracer.run('parent') do
        tracer.run('child') { sleep(0.01) }
      end

      trace = Yajl::Parser.parse(tracer.finish)['trace']

      parent = trace['frameStack']['children'].first
      parent['operation']['label'].should match('parent')
      parent['children'].size.should == 1

      child = parent['children'].first
      child['operation']['label'].should match('child')
      child['id'].to_i.should == 2
    end
  end
end