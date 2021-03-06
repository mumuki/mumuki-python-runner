require_relative './spec_helper'

describe Python2QueryHook do
  before(:all) { reload_python2_runner! }
  let(:hook) { Python2QueryHook.new }
  let!(:result) { hook.run!(hook.compile(request)) }

  it_behaves_like 'common python query hook'

  context 'passes when query is a single 2-style print' do
    let(:request) { struct query: 'print "hello"' }
    it { expect(result).to eq ["hello\n", :passed] }
  end

  context 'passes when query is a single 2-style print with multiple spaces' do
    let(:request) { struct query: 'print      "hello"' }
    it { expect(result).to eq ["hello\n", :passed] }
  end

  context 'does not redo 2-style prints in cookie' do
    let(:request) { struct query: 'print "foo"', cookie: ['print "bar"'] }
    it { expect(result).to eq ["foo\n", :passed] }
  end

  context 'does not fail if an exception was thrown in cookie in 2-style' do
    let(:request) { struct query: 'print "foo"', cookie: ['raise Exception, "bar"'] }
    it { expect(result).to eq ["foo\n", :passed] }
  end

  context 'fail if an exception was thrown in query in 2-style' do
    let(:request) { struct query: 'raise Exception, "bar"' }
    it { expect(result[1]).to eq :failed }
  end

  context 'passes when standalone query is valid and returns a string.' do
    let(:request) { struct query: '"foo"' }
    it { expect(result).to eq ["foo\n", :passed] }
  end

  context 'passes when standalone query is valid and has utf8 chars.' do
    let(:request) { struct query: '"fó" + "ò"' }
    it { expect(result).to eq ["fóò\n", :passed] }
  end

  context 'passes when standalone query fails.' do
    let(:request) { struct query: '0 / 0' }
    it { expect(result[0]).to include 'ZeroDivisionError: integer division or modulo by zero' }
    it { expect(result[1]).to eq :failed }
  end

  context 'responds with errored when query has a syntax error' do
    let(:request) { struct query: '!' }
    it { expect(result[0]).to eq %Q{!\n^\nSyntaxError: unexpected EOF while parsing (<console>, line 1)} }
    it { expect(result[1]).to eq :errored }
  end

  context 'fails when query is an incomplete print' do
    let(:request) { struct query: 'print("hello"' }
    it { expect(result).to eq ["^\nSyntaxError: invalid syntax", :errored] }
  end
end
