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
end
