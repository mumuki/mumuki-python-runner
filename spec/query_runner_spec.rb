require_relative 'spec_helper'
require 'ostruct'
require_relative '../lib/query_hook'

describe PythonQueryHook do

  let(:hook) { PythonQueryHook.new }
  let(:file) { hook.compile(request) }
  let!(:result) { hook.run!(file) }

  context 'passes when standalone query is valid.' do
    let(:request) { struct query: '4 + 5' }
    it { expect(result).to eq ["=> 9\n", :passed] }
  end

  context 'passes when query is a single print' do
    let(:request) { struct query: 'print("hello")' }
    it { expect(result).to eq ["hello\n", :passed] }
  end

  context 'passes when query is a single print with multiple spaces' do
    let(:request) { struct query: 'print("hello")' }
    it { expect(result).to eq ["hello\n", :passed] }
  end

  context 'fails when query is a broken print' do
    let(:request) { struct query: 'print("hello"' }
    it { expect(result[1]).to eq :failed }
  end

  context 'passes when query is a single 2-style print' do
    let(:request) { struct query: 'print "hello"' }
    it { expect(result).to eq ["hello\n", :passed] }
  end

  context 'passes when query is a single 2-style print with multiple spaces' do
    let(:request) { struct query: 'print      "hello"' }
    it { expect(result).to eq ["hello\n", :passed] }
  end

  context 'passes when query and content is valid.' do
    let(:request) { struct query: '4 + x', content: 'x = 10' }
    it { expect(result).to eq ["=> 14\n", :passed] }
  end
end
