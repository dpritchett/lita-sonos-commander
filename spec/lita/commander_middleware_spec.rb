require 'spec_helper'
require 'ostruct'
require 'date'

describe Lita::CommanderMiddleware do
  let(:handler) { double 'handler' }
  let(:result) { subject.build({}) }
  let(:open_sockets) { [] }
  let(:a_socket) { double 'a web socket' }

  subject { Lita::CommanderMiddleware.new(open_sockets: open_sockets) }

  it 'returns a lambda' do
    result = subject.build
    expect(result.is_a?(Proc)).to be_truthy
  end

  context 'adding a new client' do
    before { Faye::WebSocket.stub(:new).and_return(a_socket) }
    let(:result) { subject.build_socket(nil) }

    it 'builds websockets on demand' do
      expect(result).to eq(a_socket)
    end

    it 'adds the new socket to :open_sockets' do
      expect(open_sockets).to include(result)
    end
  end

  context 'client disconnects' do
    let(:event) { double 'socket event' }
    before { a_socket.stub(:send) }
    before { event.stub(:code) }
    before { event.stub(:reason) }

    it 'removes the client from :open_sockets' do
      result = subject.close_socket(a_socket, event)
      expect(result).to be_nil
      expect(open_sockets).to_not include(a_socket)
    end

    it 'logs to debug' do
      expect(Lita.logger).to receive(:debug).exactly(2).times
      subject.close_socket(a_socket, event)
    end
  end

  it 'acknowledges messages from clients' do
    event = OpenStruct.new(data: 'This is a message!')
    a_socket.stub(:send)
    expect(a_socket).to receive(:send)
    subject.handle_message(a_socket, event)
  end
end
