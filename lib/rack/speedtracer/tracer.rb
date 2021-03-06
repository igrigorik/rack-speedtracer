module Rack
  module SpeedTracer

    class TraceRecord
      def initialize(id)
        @id = id
        @start = Time.now
        @children = []
      end

      def finish; @finish = Time.now; end

      private
        # all timestamps in SpeedTracer are in milliseconds
        def range(start, finish)
          {
            'duration'  =>  ((finish - start) * 1000).to_i,
            'start'     =>  [start.to_i,  start.usec/1000].join(''),
            'end'       =>  [finish.to_i, finish.usec/1000].join('')
          }
        end
    end

    class ServerEvent < TraceRecord
      attr_accessor :children

      def initialize(id, file, line, method, name, start = Time.now, finish = nil)
        super(id)

        @file = file
        @line = line
        @method = method
        @name = name

        @start = start
        @finish = finish
      end

      def to_json
        Yajl::Encoder.encode({
          'range' => range(@start, @finish),
          'id' =>  @id,
          'operation' =>  {
            'sourceCodeLocation' =>  {
              'className'   =>  @file,
              'methodName'  =>  @method,
              'lineNumber'  =>  @line
            },
            'type' =>  'METHOD',
            'label' =>  @name
          },
          'children' =>  @children
        })
      end
    end

    class Tracer < TraceRecord
      def initialize(id, method, uri)
        super(id)

        @method = method
        @uri = uri
        @event_id = 0
        @pstack = []
      end

      def record(name, start, finish)
        @event_id += 1
        event = ServerEvent.new(@event_id, 'uknown_file', 0, 'uknown_method', name, start, finish)

        # TODO: not sure how to setup the hierarchy with Rails
        # for now, just push everythign as a root child
        @children.push event
      end

      def run(name = '', &blk)
        file, line, method = caller.first.split(':')
        method = method.gsub(/^in|[^\w]+/, '') if method

        # SpeedTracer allows us to nest events via child relationships,
        # which means that we can use a stack to keep track of the currently
        # executing events to produce a proper execution tree.
        #
        # Example execution graph:
        #
        # root
        # -- event 1
        #    ---- event 2
        # -- event 3
        #    ----- event 4
        #    ----- event 5
        #         ------ event 6
        #

        @event_id += 1
        event = ServerEvent.new(@event_id, file, line, method, name)
        @pstack.push event

        result = blk.call # execute the provided code block
        event.finish      # finalize current event timers
        @pstack.pop       # pop current event from parent stack

        if parent = @pstack.last
          parent.children.push event
        else
          # no parent, means this is a child of root node
          @children.push event
        end
        result
      end

      def finish
        super()

        Yajl::Encoder.encode({
          'trace' =>  {
            'date' =>  @start.to_i,
            'application' => 'Rack SpeedTracer',
            'range' =>  range(@start, @finish),
            'id' =>  @id,
            'frameStack' =>  {
              'range' =>  range(@start, @finish),
              'id' =>  '0',
              'operation' =>  {
                'type' =>  'HTTP',
                'label' =>  [@method, @uri].join(' ')
              },
              'children' =>  @children
            }
          }
        })
      end
    end
  end
end