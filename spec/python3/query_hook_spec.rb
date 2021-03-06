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
end
