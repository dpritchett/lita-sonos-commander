require 'spec_helper'
require 'pry'
require 'date'

describe Lita::Handlers::SonosCommander, lita_handler: true do
  let(:robot) { Lita::Robot.new(registry) }

  subject { described_class.new(robot) }

  # START:routes
  describe 'routes' do
    it {
      is_expected.to route_http(:get, '/sonos/listen')
        .to(:websocket_creator)
    }

    it {
      is_expected.to(route('Lita play url http://zombo.com')
      .to(:handle_sonos_play_url))
    }
    it {
      is_expected.to(route('Lita play url https://www.youtube.com/watch?v=dQw4w9WgXcQ')
      .to(:handle_sonos_play_url))
    }
    it {
      is_expected.to(route('Lita speak words i like turtles')
      .to(:handle_sonos_say_text))
    }
  end
  # END:routes

  describe 'sending messages to clients' do
    let(:client) { double('socket client') }
    before { subject.stub(:sockets).and_return [client] }

    it 'should work' do
      expect(subject.sockets).to include(client)
    end

    it 'should :send some commanding json to the client' do
      expect(client).to receive(:send).with(/play_url.+http.+volume/)

      subject.play_url('http://bana.nas')
    end
  end

  it 'can grab a message from chat and store it' do
    send_message 'lita speak words i like turtles'
    response = replies.last

    expect(response).to match /hello there/i
    expect(response).to match /Saved message for Alexa/
  end
end
