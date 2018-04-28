require 'pry'

require 'json'
require 'faye/websocket'
require 'uri'

module Lita
  module Handlers
    class SonosCommander < Handler

      # START:socket_registry
      @_sockets ||= []

      def self.sockets
        @_sockets
      end

      def sockets
        self.class.sockets
      end
      # END:socket_registry

      # START:routing
      http.get '/sonos/listen', :websocket_creator

      route(/^play url (http.+)/i, :handle_sonos_play_url)
      route(/^speak words (.+)/i, :handle_sonos_say_text)

      on :loaded, :register_faye
      # END:routing

      # START:create_sockets
      def websocket_creator(request, _response)
        # could probably skip straight to the Commander middleware
        # but it's cleaner to leave them all in play.

        middleware_registry.each do |mw|
          mw.middleware.call(request.env)
        end
      end
      # END:create_sockets

      # START:chat_handlers
      def handle_sonos_play_url(message)
        return message.reply('No clients found!') unless sockets.any?

        text = message.matches.last.last
        play_url message.matches.last.last

        message.reply "Command sent: [play_url] #{text}!"
      end

      def play_url(url)
        emit_message command: 'play_url', data: URI.escape(url)
      end

      def handle_sonos_say_text(message)
        return message.reply('No clients found!') unless sockets.any?

        text = message.matches.last.last
        say_text text

        message.reply "Command sent: [play_text] #{text}!"
      end

      def say_text(text)
        emit_message command: 'play_text', data: text
      end
      # END:chat_handlers

      # START:faye_hookup
      def register_faye(_arg)
        socket_manager = Lita::CommanderMiddleware.build(open_sockets: sockets)
        middleware_registry.use socket_manager
      end

      def middleware_registry
        robot.registry.config.http.middleware
      end
      # END:faye_hookup

      # START:message_emission
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
      # END:message_emission

      Lita.register_handler(self)
    end
  end
end
