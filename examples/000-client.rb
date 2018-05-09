require 'faye/websocket'
require 'eventmachine'

EM.run do
  ws = Faye::WebSocket::Client.new('ws://localhost:8080/sonos/listen')

  ws.on :open do |event|
    p [:open]
    ws.send('Hello, world!')
  end

  ws.on(:message) { |event| p [:message, event.data] }

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
end
