require 'spec_helper'
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

    it { is_expected.to route_event(:loaded).to(:register_faye) }
  end
  # END:routes

  describe 'sending messages to clients' do
    let(:client) { double('socket client') }
    before { subject.stub(:sockets).and_return [client] }

    it 'should :send some commanding json to the client' do
      expect(client).to receive(:send).with(/play_url.+http.+volume/)

      subject.play_url 'http://bana.nas'
    end

    it 'should :send some commanding json to the client' do
      expect(client).to receive(:send).with(/play_text.+turtles.+volume/)

      subject.say_text 'i like turtles'
    end

    it 'can grab a message from chat and store it' do
      send_message 'lita speak words i like turtles'
      response = replies.last

      expect(response).to match(/No clients found/i)
    end
  end

  describe 'socket registry' do
    let(:sockets) { subject.sockets }
    it 'has a socket registry shared amongst instances of the handler' do
      sockets << 'banana'
      another_one = Lita::Handlers::SonosCommander.new({})

      expect(another_one.sockets).to include('banana')
    end

    it 'allows addition and deletion to the socket registry via array methods' do
      canary = rand(10_000).to_s
      sockets << canary
      expect(sockets).to include(canary)

      sockets.delete_if { |socket| socket.eql? canary }
      expect(sockets).to_not include(canary)
    end
  end

  describe 'text serializer' do
    it 'creates a json payload' do
      result = subject.serialize(command: 'phone_call', text: 'call your mother')

      deserialized = JSON.parse(result)

      expect(deserialized.fetch('command')).to eq 'phone_call'
      expect(deserialized.dig('data', 'volume')).to_not be_falsey
    end
  end

  describe 'socket middleware registration' do
    let(:middlewares) { double 'middlewares' }
    before { subject.stub(:middleware_registry).and_return(middlewares) }

    let(:commander) { double 'commander' }
    before { Lita::CommanderMiddleware.stub(:build).and_return(commander) }

    it 'should register the commander middleware' do
      expect(middlewares).to receive(:use).with(commander)

      subject.register_faye(nil)
    end
  end

  describe ':websocket_creator' do
    let(:request) { double 'request' }
    let(:request_env) { double 'request' }
    let(:middleware) { double 'middleware' }

    before { subject.stub_chain(:middleware_registry, :each).and_return [middleware] }
    before { request.stub(:env).and_return(request_env) }

    it 'passes incoming any request environments to registered middlewares' do
      subject.websocket_creator(request, nil)
    end
  end
end
