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

  context 'passes when standalone query is valid and returns a string.' do
    let(:request) { struct query: '"foo"' }
    it { expect(result).to eq ["=> foo\n", :passed] }
  end

  context 'passes when standalone query is valid and has utf8 chars.' do
    let(:request) { struct query: '"fó" + "ò"' }
    it { expect(result).to eq ["=> fóò\n", :passed] }
  end

  context 'passes when query is a single print' do
    let(:request) { struct query: 'print("hello")' }
    it { expect(result).to eq ["hello\n", :passed] }
  end

  context 'fails when query is a broken print' do
    let(:request) { struct query: 'print("hello"' }
    it { expect(result[1]).to eq :errored }
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

  context 'passes when query is an assignment' do
    let(:request) { struct query: 'foo = 123' }
    it { expect(result).to eq ["", :passed] }
  end

  context 'is stateful' do
    let(:request) { struct query: 'print foo', cookie: ['foo = 123'] }
    it { expect(result).to eq ["123\n", :passed] }
  end

  context 'does not redo prints in cookie' do
    let(:request) { struct query: 'print "foo"', cookie: ['print "bar"'] }
    it { expect(result).to eq ["foo\n", :passed] }
  end

  context 'does not fail if an exception was thrown in cookie' do
    let(:request) { struct query: 'print "foo"', cookie: ['raise(Exception("bar"))'] }
    it { expect(result).to eq ["foo\n", :passed] }
  end

  context 'responds with errored when query has a syntax error' do
    let(:request) { struct query: '!' }
    it { expect(result[0]).to eq %q{print(string.Template("=> $result").substitute(result = !))
                                                            ^
SyntaxError: invalid syntax} }
    it { expect(result[1]).to eq :errored }
  end

  context 'responds with errored when query has an indentation error' do
    let(:request) { struct query: ' print "123"' }
    it { expect(result[0]).to eq %q{print "123"
    ^
IndentationError: unexpected indent} }
    it { expect(result[1]).to eq :errored }
  end
end
