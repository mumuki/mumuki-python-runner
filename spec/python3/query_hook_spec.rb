require_relative './spec_helper'

describe Python3QueryHook do
  before(:all) { reload_python3_runner! }
  let(:hook) { Python3QueryHook.new }
  let!(:result) { hook.run!(hook.compile(request)) }

  it_behaves_like 'common python query hook'

  context 'errors if an exception was thrown in query in 2-style' do
    let(:request) { struct query: 'raise Exception, "bar"' }
    it { expect(result[1]).to eq :errored }
  end

  context 'passes when standalone query is valid and returns a string.' do
    let(:request) { struct query: '"foo"' }
    it { expect(result).to eq ["'foo'\n", :passed] }
  end

  context 'passes when standalone query is valid and has utf8 chars.' do
    let(:request) { struct query: '"fó" + "ò"' }
    it { expect(result).to eq ["'fóò'\n", :passed] }
  end

  context 'passes when standalone query fails.' do
    let(:request) { struct query: '0 / 0' }
    it { expect(result).to eq ["  File \"<input>\", line 1, in <module>\n ZeroDivisionError: division by zero\n\n", :failed] }
  end

  context 'responds with errored when query has a syntax error' do
    let(:request) { struct query: '!' }
    pending('extra spaces') { expect(result[0]).to eq "!\n^\nSyntaxError: invalid syntax" }
    it { expect(result[1]).to eq :errored }
  end

  context 'fails when query is an incomplete print' do
    let(:request) { struct query: 'print("hello"' }
    it { expect(result).to eq ["SyntaxError: unexpected EOF while parsing", :errored] }
  end
end
