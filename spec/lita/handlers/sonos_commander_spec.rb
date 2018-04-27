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
      .to(:sonos_play_url))
    }
    it {
      is_expected.to(route('Lita play url https://www.youtube.com/watch?v=dQw4w9WgXcQ')
      .to(:sonos_play_url))
    }
    it {
      is_expected.to(route('Lita speak words i like turtles')
      .to(:sonos_say_text))
    }
  end
  # END:routes

  describe 'exploratory' do
    it "let's play" do
      subject.explorer
    end
  end
  # START:save_message
  describe ':save_message' do
    let(:body) { 'hello, alexa!' }
    it 'saves a message and acknowledges' do
      result = subject.save_message(username: 'dpritchett', message: body)

      expect(result.fetch(:message)).to eq body
    end

    it { is_expected.to route_event(:save_alexa_message).to(:save_message) }
  end
  # END:save_message

  # START:alexify
  describe ':alexify' do
    let(:message) do
      subject.save_message username: 'daniel', message: 'test message'
    end

    it 'should return a hash with an alexa-specific shape' do
      result = subject.alexify(message)
      expect(result.fetch(:mainText)).to eq('test message')
    end
  end
  # END:alexify

  it 'can grab a message from chat and store it' do
    send_message "lita newsfeed hello there #{DateTime.now}"
    response = replies.last
    expect(response =~ /hello there/i).to be_truthy
    expect(response =~ /Saved message for Alexa/).to be_truthy
  end

end

