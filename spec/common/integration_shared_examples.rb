shared_examples 'common python runner' do
  it 'answers a valid hash when submission is ok' do
    response = bridge.run_tests!(test: 'def test_foo_returns_true(self):
    self.assertFalse(foo())',
                                 extra: '',
                                 content: "def foo():\n    return False\n",
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{result: '', status: :passed, title: 'Foo returns true'}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  it 'answers a valid hash when submission is ok with a full-defined test' do
    response = bridge.run_tests!(
        test: '
class TestFoo(unittest.TestCase):
    def test_true(self):
        self.assertFalse(foo())',
        extra: '',
        content: "def foo():\n    return False\n",
        expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{result: '', status: :passed, title: 'True'}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  it 'answers a valid hash when query is ok' do
    response = bridge.run_query!(extra: 'x = 3',
                                 content: 'y = 6',
                                 query: 'x + y')
    expect(response).to eq(status: :passed, result: "9\n")
  end

  it 'answers a valid hash when submission has syntax errors' do
    response = bridge.
        run_tests!(test: '
def test_foo_returns_false(self):
    self.assertFalse(foo())',
                   extra: '',
                   content: 'no#COMPILA!"',
                   expectations: [])

    expect(response).to eq(status: :errored,
                           expectation_results: [],
                           feedback: '',
                           test_results: [],
                           result: "Traceback (most recent call last):\n" +
                                   "  File \"solution.py\", line 8, in <module>\n" +
                                   "    no#COMPILA!\"\n" +
                                   "NameError: name 'no' is not defined\n",
                           response_type: :unstructured)
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

  it 'exposes runner as structured' do
    expect(bridge.info['features']).to include('structured' => true)
  end
end
