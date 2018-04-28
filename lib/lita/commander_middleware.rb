class Lita::CommanderMiddleware
  def self.build(open_sockets:)
    new.build open_sockets: open_sockets
  end

  def handle_env_has_socket(env, open_sockets)
    ws = Faye::WebSocket.new(env)
    open_sockets << ws
    Lita.logger.debug "Sonos client count: #{open_sockets.count}"

    ws.on :message do |event|
      ws.send({ message: event.data }.to_json)

      sleep 0.5
      ws.send({ message: 'WE DID IT TWITCH', command: 'echo' }.to_json)
    end

    ws.on :close do |event|
      open_sockets.delete_if { |s| s == ws }
      Lita.logger.debug "Sonos client count: #{open_sockets.count}"

      p [:close, event.code, event.reason]
      ws = nil
    end

    # Return async Rack response
    ws.rack_response
  end

  def build(open_sockets:)
    return lambda do |env|
      if Faye::WebSocket.websocket?(env)
        handle_env_has_socket env, open_sockets
      else
        [
          200,
          { 'Content-Type' => 'text/plain' },
          ['Hello from a Lita chatbot! Feed me a websocket connection!']
        ]
      end
    end
  end
end
