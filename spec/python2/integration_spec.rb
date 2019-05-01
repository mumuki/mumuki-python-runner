require_relative './spec_helper'
require 'mumukit/bridge'

describe 'python2 integration test' do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://localhost:4567') }

  before(:all) do
    @pid = Process.spawn 'rackup config2.ru -p 4567', err: '/dev/null'
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
                           test_results: [{result: "NameError: global name 'foo' is not defined", status: :failed, title: 'Foo returns false'}],
                           response_type: :structured)
  end

  it 'answers a valid hash when submission presents version-specific expectations and behaviour' do
    response = bridge.run_tests!(
        test: '
class TestFoo(unittest.TestCase):
    def test_map_returns_list(self):
        self.assertEqual(foo(), [1, 2, 3])',
        extra: '',
        content: "print 'hello'\ndef foo():\n    return map(lambda x: x+1, range(0, 3))\n",
        expectations: [
          {binding: '*', inspection: 'Declares:foo'},
          {binding: 'foo', inspection: 'UsesLambda'},
          {binding: '*', inspection: 'Declares:bar'}
        ])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: "Map returns list", status: :passed, result: ""}],
                           status: :passed_with_warnings,
                           feedback: '',
                           expectation_results: [
                             {binding: '*', inspection: 'Declares:foo', result: :passed},
                             {binding: 'foo', inspection: 'UsesLambda', result: :passed},
                             {binding: '*', inspection: 'Declares:bar', result: :failed},
                             {binding: '*', inspection: 'DoesConsolePrint', result: :failed}
                           ],
                           result: '')
  end

  it 'exposes python version' do
    expect(bridge.info['language']).to include('version' => '2.7.16')
  end
end
