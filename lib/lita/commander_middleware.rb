class Lita::CommanderMiddleware
  def self.build(open_sockets:)
    new.build open_sockets: open_sockets
  end

  attr_reader :env, :open_sockets

  def build(open_sockets:)
    @open_sockets = open_sockets

    return lambda do |env|
      if Faye::WebSocket.websocket?(env)
        @env = env
        handle_env_has_socket
      else
        [
          200,
          { 'Content-Type' => 'text/plain' },
          ['Hello from a Lita chatbot! Feed me a websocket connection!']
        ]
      end
    end
  end

  def build_socket(env)
    ws = Faye::WebSocket.new(env)
    open_sockets << ws
    Lita.logger.debug "Sonos client count: #{open_sockets.count}"
    ws
  end

  def close_socket(ws)
    open_sockets.delete_if { |s| s == ws }
    Lita.logger.debug "Sonos client count: #{open_sockets.count}"
    p [:close, event.code, event.reason]
    ws = nil
  end

  def handle_message(ws, event)
    ws.send({ message: event.data }.to_json)
    maybe_send_debug_message(ws)
  end

  def maybe_send_debug_message(ws)
    sleep 0.5
    ws.send({ message: 'WE DID IT TWITCH', command: 'echo' }.to_json)
  end

  def handle_env_has_socket
    ws = build_socket(env)

    ws.on(:message) { |event| handle_message(ws, event) }
    ws.on(:close) { |event| close_socket(ws) }

    # Return async Rack response
    ws.rack_response
  end
end
