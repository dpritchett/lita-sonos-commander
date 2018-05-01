class Lita::CommanderMiddleware
  def self.build(open_sockets:)
    new(open_sockets: open_sockets).build
  end

  attr_reader :env, :open_sockets

  def initialize(open_sockets:)
    @open_sockets = open_sockets
  end

  def build
    lambda do |env|
      if Faye::WebSocket.websocket?(env)
        @env = env
        handle_env_has_socket
      else
        http_explainer_payload
      end
    end
  end

  def build_socket(env)
    ws = Faye::WebSocket.new(env)
    open_sockets << ws
    Lita.logger.debug "Sonos client count: #{open_sockets.count}"
    ws
  end

  def close_socket(ws, event)
    open_sockets.delete_if { |s| s == ws }
    Lita.logger.debug "Sonos client count: #{open_sockets.count}"
    Lita.logger.debug "Socket close: #{[:close, event.code, event.reason]}"
    ws = nil
  end

  def handle_message(ws, event)
    ws.send({ message: "ACK: #{event.data}" }.to_json)
  end

  def send_welcome_message(ws)
    payload = { message: 'Welcome to Lita Sonos Commander!', command: 'echo' }
    ws.send(payload.to_json)
  end

  def handle_env_has_socket
    ws = build_socket(env)

    send_welcome_message(ws)

    ws.on(:message) { |event| handle_message(ws, event) }
    ws.on(:close) { |event| close_socket(ws, event) }

    # Return async Rack response
    ws.rack_response
  end

  def http_explainer_payload
    [
      200,
      { 'Content-Type' => 'text/plain' },
      ['Hello from a Lita chatbot! Feed me a websocket connection!']
    ]
  end
end
