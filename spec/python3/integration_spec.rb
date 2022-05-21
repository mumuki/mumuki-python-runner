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

  it 'answers a valid hash when submission is ok and uses plotting tools' do
    response = bridge.
        run_tests!(test: <<~EOF,
                    def test_nothing(self):
                        pass
                    EOF
                   extra: '',
                   content: <<~EOF,
                    import matplotlib.pyplot as plt
                    import seaborn as sns
                    import pandas as pd

                    sns.set_theme()

                    flights_long = pd.DataFrame([
                      {'year': 1949, 'month': 'Jan', 'passengers': 112},
                      {'year': 1949, 'month': 'Feb', 'passengers': 118},
                      {'year': 1949, 'month': 'Mar', 'passengers': 132},
                      {'year': 1949, 'month': 'Apr', 'passengers': 129},
                      {'year': 1949, 'month': 'May', 'passengers': 121},
                      {'year': 1949, 'month': 'Jun', 'passengers': 135},
                      {'year': 1949, 'month': 'Jul', 'passengers': 148},
                      {'year': 1949, 'month': 'Aug', 'passengers': 148},
                      {'year': 1949, 'month': 'Sep', 'passengers': 136},
                      {'year': 1949, 'month': 'Oct', 'passengers': 119}])
                    flights = flights_long.pivot("month", "year", "passengers")

                    f, ax = plt.subplots(figsize=(9, 6))
                    sns.heatmap(flights, annot=True, fmt="d", linewidths=.5, ax=ax)

                    EOF
                   expectations: []).
        reject { |k, _v| k == :result }

    expect(response).to eq(response_type: :structured,
        test_results: [{result: '', status: :passed, title: 'Nothing'}],
        status: :passed,
        feedback: '',
        expectation_results: [])
  end

  it 'answers a valid hash when extra imports pandas and query uses a DataFrame' do
    response = bridge.run_query!(extra: 'import pandas as pd',
                                 content: '',
                                 query: 'pd.DataFrame([{"name": "mary", "surname": "doe"}, {"name": "john", "surname": "doe"}])')
    expect(response).to eq(status: :passed, result: "   name surname\n0  mary     doe\n1  john     doe\n")
  end

  it 'answers a valid hash when importing and using pandas in query' do
    response = bridge.run_query!(extra: '',
                                 content: '',
                                 query: 'pd.DataFrame([{"name": "mary", "surname": "doe"}, {"name": "john", "surname": "doe"}])',
                                 cookie: ['import pandas as pd'])
    expect(response).to eq(status: :passed, result: "   name surname\n0  mary     doe\n1  john     doe\n")
  end

  it 'answers a valid hash when extra imports pandas and query plots a DataFrame' do
    response = bridge.run_query!(extra: 'import pandas as pd',
                                 content: 'df = pd.DataFrame([{"a": 1, "bar": 2}, {"a": "john", "bar": 2}])',
                                 query: 'df.plot.bar()')
    expect(response).to eq(status: :passed, result: "<AxesSubplot:>\n")
  end

  it 'answers a valid hash when submitting an interactive query that fails' do
    response = bridge.run_try!(
        query: '4 >= 9',
        cookie: [],
        goal: { kind: 'last_query_equals', value: '4 < 9' })
    expect(response).to eq(status: :failed,
                           query_result: {result: "False", status: :passed},
                           result: "query should be '4 < 9' but was '4 >= 9'")
  end

  it 'answers a valid hash when submitting an interactive query that fails and raises an error' do
    response = bridge.run_try!(
        query: 'print 4',
        cookie: [],
        goal: { kind: 'last_query_equals', value: '4 < 9' })
    expect(response).to eq(status: :failed,
                           query_result: {result: "  File \"<input>\", line 1\n     print 4\n           ^\n SyntaxError: Missing parentheses in call to 'print'. Did you mean print(4)?", status: :errored},
                           result: "query should be '4 < 9' but was 'print 4'")
  end


  it 'answers a valid hash when submitting an interactive query with regexps that passes' do
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

  it 'answers a valid hash when submitting an interactive query with regexps that fails' do
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

  it 'exposes pandas version' do
    expect(bridge.info['libraries']['pandas']).to eq('1.3.3')
  end

  it 'exposes matplotlib version' do
    expect(bridge.info['libraries']['matplotlib']).to eq('3.5.3')
  end

  it 'exposes seaborn version' do
    expect(bridge.info['libraries']['seaborn']).to eq('0.12.0')
  end

  it 'exposes external editor' do
    expect(bridge.info['external_editor_instructions']['Visual Studio Code']['en']).to_not eq ''
    expect(bridge.info['external_editor_instructions']['Jupyter']['en']).to_not eq ''
  end
end
