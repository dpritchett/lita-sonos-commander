class Lita::CommanderMiddleware 
  def self.build(commander)
    return lambda do |env|

      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env)

        commander.push_socket(ws)

        ws.on :open do |event|
        end

        ws.on :connect do |event|
        end

        ws.on :message do |event|
          ws.send({ message: event.data }.to_json)

          sleep 0.5
          ws.send({ message: 'WE DID IT TWITCH', command: 'echo' }.to_json)
        end

        ws.on :close do |event|
          commander.pop_socket(ws)

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
      @@_sockets ||= []
      middleware = robot.registry.config.http.middleware
      result = middleware.use App
    end

    def sonos_connector(request, response)
      middlewares.each do |mw|
        mw.middleware.call(request.env)
      end
    end
  end
end
