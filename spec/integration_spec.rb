require 'spec_helper'
require 'mumukit/bridge'

describe 'integration test' do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://localhost:4567') }

  before(:all) do
    @pid = Process.spawn 'rackup -p 4567', err: '/dev/null'
    sleep 3
  end
  after(:all) { Process.kill 'TERM', @pid }

  it 'answers a valid hash when submission is ok' do
    response = bridge.run_tests!(test: '
class TestFoo(unittest.TestCase):
    def test_true(self):
        self.assertFalse(foo())',
                                 extra: '',
                                 content: "def foo():\n    return False\n",
                                 expectations: [])

    expect(response).to eq(response_type: :unstructured,
                           test_results: [],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: ".\n----------------------------------------------------------------------\nRan 1 test in 0.000s\n\nOK\n")
  end

  it 'answers a valid hash when submission is not ok' do
    response = bridge.
        run_tests!(test: '
class TestFoo(unittest.TestCase):
    def test_true(self):
        self.assertFalse(foo())',
                   extra: '',
                   content: 'dsfsdf(asas',
                   expectations: []).
        reject { |k, _v| k == :result }

    expect(response).to eq(status: :failed,
                           expectation_results: [],
                           feedback: '',
                           test_results: [],
                           response_type: :unstructured)
  end


  it 'answers a valid hash when query is ok' do
    response = bridge.run_query!(extra: 'x = 3',
                                 content: 'y = 6',
                                 query: 'x + y')
    expect(response).to eq(status: :passed, result: "=> 9\n")
  end

  it 'answers a valid hash when query is not ok' do
    response = bridge.
        run_query!(extra: '',
                   content: '',
                   query: 'foo.bar()')
    expect(response[:status]).to eq(:failed)
  end

  it 'status => aborted when using an infinite recursion' do
    response = bridge.
        run_query!(extra: '',
                   content: "def foo():\n    foo()",
                   query: 'foo()')

    expect(response[:status]).to eq(:failed)
    expect(response[:result]).to include('maximum recursion depth exceeded')
  end

end
