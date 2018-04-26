require 'pry'

require 'json'
require 'faye/websocket'
require 'uri'

module Lita
  module Handlers
    class SonosCommander < Handler

      @_sockets ||= []

      def self.sockets
        @_sockets
      end


      http.get '/sonos/listen', :sonos_connector

      route(/^play_url (.+)/, :sonos_play_url)
      route(/^say_text (.+)/, :sonos_say_text)

      on :loaded, :register_faye

      def clients?
        sockets.any?
      end

      def sonos_play_url(message)
        return message.reply('No clients found!') unless clients?

        text = message.matches.last.last
        emit_message command: 'play_url', data: URI.escape(text)

        message.reply "Command sent: [play_url] #{text}!"
      end

      def sonos_say_text(message)
        return message.reply('No clients found!') unless clients?

        text = message.matches.last.last
        emit_message command: 'play_text', data: text

        message.reply "Command sent: [play_text] #{text}!"
      end

      def emit_message(command:, data:)
        puts "emitting #{command} \t #{data}"
        sockets.each do |ws|
          ws.send serialize(command: command, text: data)
        end
      end

      def serialize(command:, text:)
        {
          command: command,
          data: { text: text, volume: 20 }
        }.to_json
      end

      def middlewares
        robot.registry.config.http.middleware
      end

      def sockets
        self.class.sockets
      end

      def push_socket(socket)
        puts "Tracking socket #{socket}"
        sockets << socket
      end

      def pop_socket(socket)
        puts "Forgetting socket #{socket}"
        sockets.delete_if { |s| s == socket }
      end

      def register_faye(arg)
        middleware = robot.registry.config.http.middleware
        socket_manager = Lita::CommanderMiddleware.build(self)
        middleware.use socket_manager
      end

      def sonos_connector(request, response)
        middlewares.each do |mw|
          mw.middleware.call(request.env)
        end
      end

      Lita.register_handler(self)
    end
  end
end
