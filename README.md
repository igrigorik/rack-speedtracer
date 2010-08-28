Rack::SpeedTracer
=========

Blog post: [Speed Tracer Server-side Tracing with Rack](http://www.igvita.com/2010/07/19/speed-tracer-server-side-tracing-with-rack/)

Rack::SpeedTracer middleware provides server-side tracing capabilities to any Rack compatible app. Include the middleware, instrument your application, and then load it in your Google Chrome + SpeedTracer to view detailed breakdown of your JavaScript/CSS load times, GC cycles, as well as, server side performance data provided by this middleware - you can preview both server side and client side performance data all within the same view in SpeedTracer!

Preview of a sample, server side Rails trace (see below for setup) in SpeedTracer:
![rails trace](http://img.skitch.com/20100717-cd31bhd5dh13sge7c2q1hefh4p.png)

Features
---------

* Auto Rails 3 instrumentation (see example below)
* Memory, or Redis storage backend
  * Redis backend allows trace expiration (via :trace_ttl), and custom namespaces (via :namespace)

Todo / Wishlist
---------------

* Authentication / optional enable, ala rack-bug: IP-based, password based
  * At the moment, every request will record & store a trace
  * Could also do conditional tracing based on a request header: 'X-SpeedTracer: true'

Without authentication, I wouldn't recommend running this middleware in production, unless you add some extra logic. For a capped memory footprint, use Redis backend with a TTL to expire your traces after some reasonable amount of time.

How it works
------------

Rack::SpeedTracer provides a Tracer class which you can use to instrument your code. From there, the trace details are stored as a JSON blob, and a special X-TraceUrl header is sent back to the client. If the user clicks on the network resource that corresponds to a request which returned a X-TraceUrl header, then SpeedTracer will make a request to our app to load the server side trace. Rack::SpeedTracer responds to this request and returns the full trace - aka, the data is provided on demand.

### Quickstart Guide with Rack ###

    gem install rack-speedtracer

    # in your rack app / rackup file
    use Rack::SpeedTracer

    # in your app
    env['st.tracer'].run('name of operation') do
      ... your code ...
    end

Check out a full sample rack app: examples/runner.rb

### Instrumenting Rails 3 application ###
Rails 3 provides new [Notifications API](http://edgeapi.rubyonrails.org/classes/ActiveSupport/Notifications.html), which we can use to automatically instrument your Rails applications! It's as easy as:

    # in your Gemfile
    gem 'rack-speedtracer', :require => 'rack/speedtracer'

    # in development.rb environment
    config.middleware.use Rack::SpeedTracer

### Manually instrumenting Rails ###
To produce a server-side trace equivalent to one in the screenshot above:

    # in your Gemfile
    gem 'rack-speedtracer', :require => 'rack/speedtracer'

    # in development.rb environment
    config.middleware.use Rack::SpeedTracer

    # define a widgets controller
    class WidgetsController < ApplicationController
      def index
        env['st.tracer'].run('Widgets#index') do
          env['st.tracer'].run("ActiveRecord: Widgets.all") do
            Widget.all
          end

          env['st.tracer'].run('Render') { render :text => 'oh hai' }
        end
      end
    end

Speed Tracer
------------

Speed Tracer is a Google Chrome extension to help you identify and fix performance problems in your web applications. It visualizes metrics that are taken from low level instrumentation points inside of the browser and analyzes them as your application runs. Speed Tracer is available as a Chrome extension and works on all platforms where extensions are currently supported (Windows and Linux).

Using Speed Tracer you are able to get a better picture of where time is being spent in your application. This includes problems caused by JavaScript parsing and execution, layout, CSS style recalculation and selector matching, DOM event handling, network resource loading, timer fires, XMLHttpRequest callbacks, painting, and more.

* [Official SpeedTracer site](http://code.google.com/webtoolkit/speedtracer/)
* [Install SpeedTracer](http://code.google.com/webtoolkit/speedtracer/get-started.html#downloading)
* [Getting Started](http://code.google.com/webtoolkit/speedtracer/speed-tracer-examples.html)
* [Google Group](https://groups.google.com/group/speedtracer/topics)

License
-------

(The MIT License)

Copyright © 2010 Ilya Grigorik

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.