require 'spec_helper'

describe BooticClient do
  it 'should have a version number' do
    expect(BooticClient::VERSION).not_to eql(nil)
  end

end
