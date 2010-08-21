module ActionController
  module Instrumentation
    def process_action(action, *args)
      raw_payload = {
        :controller => self.class.name,
        :action     => self.action_name,
        :params     => request.filtered_parameters,
        :formats    => request.formats.map(&:to_sym),
        :method     => request.method,
        :path       => (request.fullpath rescue "unknown"),

        # need to pass in the tracer object to auto-instrument Rails
        :tracer     => request.env['st.tracer']
      }

      ActiveSupport::Notifications.instrument("start_processing.action_controller", raw_payload.dup)

      ActiveSupport::Notifications.instrument("process_action.action_controller", raw_payload) do |payload|
        result = super
        payload[:status] = response.status
        append_info_to_payload(payload)
        result
      end
    end
  end
end

module Rack
  module SpeedTracer
    class Railtie < Rails::Railtie
      config.speedtracer = ActiveSupport::OrderedOptions.new

      initializer "speedtracer.initialize" do |app|
        app.middleware.use Rack::SpeedTracer

        ActiveSupport::Notifications.subscribe do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          name = event.name

          case event.name
            when 'start_processing.action_controller' then
              @tracer = event.payload[:tracer]

            when 'process_action.action_controller' then
              # in theory, can report controller execution time by
              # db_runtime - view_runtime.. skipping for now.

            when 'sql.active_record' then
              name = [event.payload[:name], event.payload[:sql]].join(": ")
          end

          @tracer.record(name, event.time, event.end)
        end

      end
    end

  end
end
