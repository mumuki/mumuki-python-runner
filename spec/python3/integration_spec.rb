require_relative './spec_helper'
require 'mumukit/bridge'

describe 'python3 integration test' do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://localhost:4567') }

  before(:all) do
    @pid = Process.spawn 'rackup config3.ru -p 4567', err: '/dev/null'
    sleep 3
  end
  after(:all) { Process.kill 'TERM', @pid }

  it_behaves_like 'common python runner'

  it 'answers a valid hash when submission is not ok because of a global name' do
    response = bridge.
        run_tests!(test: '
def test_foo_returns_false(self):
    self.assertFalse(foo())',
                   extra: '',
                   content: '',
                   expectations: []).
        reject { |k, _v| k == :result }

    expect(response).to eq(status: :failed,
                           expectation_results: [],
                           feedback: '',
                           test_results: [{result: "NameError: name 'foo' is not defined", status: :failed, title: 'Foo returns false'}],
                           response_type: :structured)
  end


  it 'exposes python version' do
    expect(bridge.info['language']).to include('version' => '3.7.3')
  end

  it 'exposes ruby comment type' do
    expect(bridge.info['comment_type']).to eq('ruby')
  end
end
