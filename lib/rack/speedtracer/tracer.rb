require 'json'

module Rack
  module SpeedTracer

    class Tracer
      def initialize(id, method, uri)
        @id = id
        @method = method
        @uri = uri

        @start = Time.now
        @children = []
      end

      def run(name = '', &blk)
        file, line, method = caller.first.split(':')
        method = method.gsub(/^in|[^\w]+/, '') if method

        start =  Time.now
        blk.call
        finish = Time.now

        @children.push({
                         'range' =>  range(start, finish),
                         'id' =>  @children.size,
                         'operation' =>  {
                           'sourceCodeLocation' =>  {
                             'className'   =>  file,
                             'methodName'  =>  method,
                             'lineNumber'  =>  line
                           },
                           'type' =>  'METHOD',
                           'label' =>  name
                         },
                         'children' =>  []
        })
      end

      def finish
        now = Time.now

        {
          'trace' =>  {
            'date' =>  @start.to_i,
            'application' => 'Rack SpeedTracer',
            'range' =>  range(@start, now),
            'id' =>  @id,
            'frameStack' =>  {
              'range' =>  range(@start, now),
              'id' =>  '0',
              'operation' =>  {
                'type' =>  'HTTP',
                'label' =>  [@method, @uri].join(' ')
              },
              'children' =>  @children
            }
          }
        }.to_json
      end

      private
        def range(start, finish)
          {
            # all timestamps are in milliseconds
            'duration'  =>  ((finish - start) * 1000).to_i,
            'start'     =>  [start.to_i,  start.usec/1000].join(''),
            'end'       =>  [finish.to_i, finish.usec/1000].join('')
          }
        end
    end
  end
end
