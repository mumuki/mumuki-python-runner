require_relative 'spec_helper'
require 'ostruct'
require_relative '../lib/query_hook'

describe QueryHook do

  let(:hook) { QueryHook.new }
  let(:file) { hook.compile(request) }
  let!(:result) { hook.run!(file) }

  context 'passes when standalone query is valid.' do
    let(:request) { OpenStruct.new(query: '4 + 5') }
    it { expect(result).to eq ["=> 9\n", :passed] }
  end

  context 'passes when query and content is valid.' do
    let(:request) { OpenStruct.new(query: '4 + x', content: 'x = 10') }
    it { expect(result).to eq ["=> 14\n", :passed] }
  end
end