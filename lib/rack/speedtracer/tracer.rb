module Rack
  module SpeedTracer

    class Tracer
      def initialize(id, method, uri)
        @id = id
        @method = method
        @uri = uri

        @start = Time.now.to_f
        @children = []
      end

      def run(name = '', &blk)
        file, line, method = caller.first.split(':')
        method = method.gsub(/^in|[^\w]+/, '') if method

        start =  Time.now.to_f
        blk.call
        finish = Time.now.to_f

        @children.push({
                         'range' =>  range(start, finish),
                         'id' =>  @children.size,
                         'operation' =>  {
                           'sourceCodeLocation' =>  {
                             'fileName'    =>  file,
                             'methodName'  =>  method,
                             'lineNumber'  =>  line
                           },
                           # 'type' =>  'VIEW_RESOLVER',
                           'label' =>  name
                         },
                         'children' =>  []
        })
      end

      def to_json
        now = Time.now.to_f

        {
          'trace' =>  {
            'date' =>  @start.to_i,
            'application' => 'Rack SpeedTracer',
            'range' =>  range(@start, now),
            'id' =>  @id,
            'frameStack' =>  {
              # 'range' =>  {
              #   'duration' =>  2374,
              #   'start' =>  1268967930664,
              #   'end' =>  1268967933038
              # },
              'id' =>  '0',
              'operation' =>  {
                'type' =>  'HTTP',
                'label' =>  [@method, @uri].join(' ')
              },
              'children' =>  @children
            }
          }
        }

      end

      private

        def range(start, finish)
          {
            'duration'  =>  ((finish - start) * 1000).to_i, # duration is reported in milliseconds
            'start'     =>  start.to_i,                     # TODO: millisecond granularity?
            'end'       =>  finish.to_i                     # TODO: millisecond granularity?
          }
        end

    end
  end

end
