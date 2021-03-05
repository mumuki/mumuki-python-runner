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

  it 'answers a valid hash when submission presents version-specific expectations and behaviour' do
    response = bridge.run_tests!(
        test: '
class TestFoo(unittest.TestCase):
    def test_map_returns_map(self):
        self.assertNotEqual(foo(), [1, 2, 3])',
        extra: '',
        content: "print('hello')\ndef foo():\n    return map(lambda x: x+1, range(0, 3))\n",
        expectations: [
          {binding: '*', inspection: 'Declares:foo'},
          {binding: 'foo', inspection: 'UsesLambda'},
          {binding: '*', inspection: 'Declares:bar'}
        ])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: "Map returns map", status: :passed, result: ""}],
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

  it 'answers a valid hash when submitting an interactive query that passes' do
    response = bridge.run_try!(
        query: '5 in [1, 2, 4]',
        cookie: [
          '4 in [1, 2, 4]',
          '5 in [1, 2, 3]',
        ],
        goal: {
          kind: 'queries_match',
          regexps: [
            '\W*4\W*in\W*\[\W*1\W*,\W*2\W*,\W*4\W*\]',
            '\W*5\W*in\W*\[\W*1\W*,\W*2\W*,\W*4\W*\]'
          ]
        })
    expect(response).to eq(status: :passed,
                           query_result: {result: "False", status: :passed},
                           result: "goal was met successfully")
  end

  it 'answers a valid hash when submitting an interactive query that fails' do
    response = bridge.run_try!(
        query: '3 in [1, 2, 3]',
        cookie: [
          '4 in [1, 2, 4]',
          '5 in [1, 2, 3]',
        ],
        goal: {
          kind: 'queries_match',
          regexps: [
            '\W*4\W*in\W*\[\W*1\W*,\W*2\W*,\W*4\W*\]',
            '\W*5\W*in\W*\[\W*1\W*,\W*2\W*,\W*4\W*\]'
          ]
        })
    expect(response).to eq(status: :failed,
                           query_result: {result: "True", status: :passed},
                           result: 'All the required queries must be executed')
  end


  it 'exposes python version' do
    expect(bridge.info['language']).to include('version' => '3.7.3')
  end

  it 'exposes ruby comment type' do
    expect(bridge.info['comment_type']).to eq('ruby')
  end
end
