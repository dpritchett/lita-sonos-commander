require 'spec_helper'
require 'date'

describe Lita::CommanderMiddleware do
  let(:handler) { double 'handler' }
  let(:result) { subject.build({}) }

  it 'returns a lambda' do
    result = subject.class.build(open_sockets: [])
    expect(result.is_a?(Proc)).to be_truthy
  end
end
