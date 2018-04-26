require 'pry'
module Lita
  module Handlers
    class SonosCommander < Handler
      # insert handler code here

      require 'faye/websocket'


      http.get '/sonos/listen', :sonos_connector

      route /^sonos (.+)/, :send_to_sonos
      route /^explore/, :call_explorer

      on :loaded, :register_faye

      def middlewares
        robot.registry.config.http.middleware
      end

      App = lambda do |env|
        if Faye::WebSocket.websocket?(env)
          ws = Faye::WebSocket.new(env)

          ws.on :message do |event|
            ws.send(event.data)

            sleep 2
            ws.send "WE DID IT TWITCH"
          end

          ws.on :close do |event|
            p [:close, event.code, event.reason]
            ws = nil
          end

          # Return async Rack response
          ws.rack_response

        else
          # Normal HTTP request
          [200, {'Content-Type' => 'text/plain'}, ['Hello']]
        end
      end

      def register_faye(arg)
        middleware = robot.registry.config.http.middleware
        result = middleware.use App
#        binding.pry
      end

      def send_to_sonos(message)
        #binding.pry
      end

      def call_explorer(_message); explorer; end

      def explorer
        middleware = robot.registry.config.http.middleware
      end

      def sonos_connector(request, response)
        #binding.pry
        middlewares.each do |mw|
        #  binding.pry
          mw.middleware.call(request.env)
        end
      end


      Lita.register_handler(self)
    end
  end
end
