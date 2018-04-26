require 'pry'

require 'json'
require 'faye/websocket'
require 'uri'

module Lita
  module Handlers
    class SonosCommander < Handler

      http.get '/sonos/listen', :sonos_connector

      route %r{/^play_url (.+)}, :sonos_play_url
      route %r{/^say_text (.+)}, :sonos_say_text

      on :loaded, :register_faye

      def sonos_play_url(message)
        text = message.matches.last.last
        emit_message command: 'play_url', data: URI.escape(text)
      end

      def sonos_say_text(message)
        text = message.matches.last.last
        emit_message command: 'play_text', data: text
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

      def self.sockets
        @@_sockets ||= []
      end

      def self.add_socket(socket)
        puts "Tracking socket #{socket}"
        @@_sockets ||= []
        @@_sockets << socket
      end

      def self.drop_socket(socket)
        puts "Forgetting socket #{socket}"
        sockets.delete_if { |s| s == socket }
      end

      def register_faye(arg)
        @@_sockets ||= []
        middleware = robot.registry.config.http.middleware
        socket_manager = Lita::CommanderMiddleware.build
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
