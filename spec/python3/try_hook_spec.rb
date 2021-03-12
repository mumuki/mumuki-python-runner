require_relative './spec_helper'
require 'ostruct'

describe Python3TryHook do
  let(:hook) { Python3TryHook.new }
  let(:file) { hook.compile(request) }
  let(:result) { hook.run!(file) }

  context 'try with last_query_equals goal' do
    let(:goal) { { kind: 'last_query_equals', value: '"something"' } }

    context 'when query matches' do
      let(:request) { struct query: '"something"', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq "'something'" }
    end

    context 'when query does not match' do
      let(:request) { struct query: '"somethingElse"', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq "'somethingElse'" }
    end

    context 'when query fails' do
      let(:request) { struct query: '0 / 0', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:status]).to eq :failed }
      it { expect(result[2][:result]).to eq "  File \"<input>\", line 1, in <module>\n ZeroDivisionError: division by zero" }
    end

    context 'when query errors' do
      let(:request) { struct query: 'print 4', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:status]).to eq :failed }
      it { expect(result[2][:result]).to include "SyntaxError: Missing parentheses in call to 'print'. Did you mean print(4)?" }
    end
  end

  context 'try with last_query_matches goal' do
    let(:goal) { { kind: 'last_query_matches', regexp: /print(.*)/ } }

    context 'when query matches' do
      let(:request) { struct query: 'print(3)', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '3' }
    end

    context 'when query does not match' do
      let(:request) { struct query: 'abs(2)', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq '2' }
    end
  end

  context 'try with last_query_matches goal, with string' do
    let(:goal) { { kind: 'last_query_matches', regexp: '^print(.*)' } }

    context 'when query matches' do
      let(:request) { struct query: 'print(3)', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '3' }
    end

    context 'when query does not match' do
      let(:request) { struct query: 'abs(2)', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq '2' }
    end
  end

  context 'try with last_query_matches goal, with =' do
    let(:goal) { { kind: 'last_query_matches', regexp: '^4\W+!=\W+5' } }

    context 'when query matches' do
      let(:request) { struct query: '4  !=  5  ', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq 'True' }
    end

    context 'when query does not match' do
      let(:request) { struct query: '4 != 4   ', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq 'False' }
    end
  end

  context 'try with last_query_matches goal, with <' do
    let(:goal) { { kind: 'last_query_matches', regexp: '^4\W+<\W+5' } }

    context 'when query matches' do
      let(:request) { struct query: '4  <  5  ', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq 'True' }
    end

    context 'when query does not match' do
      let(:request) { struct query: '4 < 4   ', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq 'False' }
    end
  end

  context 'try with last_query_matches goal, with prefix spaces' do
    let(:goal) { { kind: 'last_query_matches', regexp: '^4\W+<\W+5' } }

    context 'when query matches' do
      let(:request) { struct query: '    4  <  5', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2]).to eq result: "  File \"<input>\", line 1\n     4  <  5\n     ^\n IndentationError: unexpected indent", status: :failed }
    end

    context 'when query does not match' do
      let(:request) { struct query: '    4 < 4', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2]).to eq result: "  File \"<input>\", line 1\n     4 < 4\n     ^\n IndentationError: unexpected indent", status: :failed }
    end
  end

  context 'try with last_query_outputs goal' do
    let(:goal) { { kind: 'last_query_outputs', output: '3' } }

    context 'and query with said output' do
      let(:request) { struct query: '1 + 2', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '3' }
    end

    context 'and query with a different output' do
      let(:request) { struct query: '5', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq '5' }
    end
  end

  context 'try with query_fails goal' do
    let(:goal) { { kind: 'query_fails', query: 'my_var' } }

    context 'when query makes said query pass' do
      let(:request) { struct query: 'my_var = 2;', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq '' }
    end

    context 'when query does not make said query pass' do
      let(:request) { struct query: '', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '' }
    end
  end

  context 'try with query_passes goal' do
    let(:goal) { { kind: 'query_passes', query: 'my_var' } }

    context 'when query makes said query pass' do
      let(:request) { struct query: 'my_var = 2;', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '' }
    end

    context 'when query does not make said query pass' do
      let(:request) { struct query: '', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq '' }
    end
  end

  context 'try with query_outputs goal' do
    let(:goal) { { kind: 'query_outputs', query: 'my_var', output: '55' } }

    context 'when query generates said output' do
      let(:request) { struct query: 'my_var = 55;', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '' }
    end

    context 'when query does not generate said output' do
      let(:request) { struct query: 'my_var = 28', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq '' }
    end
  end

  context 'try with last_query_passes goal' do
    let(:goal) { { kind: 'last_query_passes' } }

    context 'when query passes' do
      let(:request) { struct query: '123', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '123' }
    end

    context 'when query fails' do
      let(:request) { struct query: 'asdasd', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2]).to eq result: "  File \"<input>\", line 1, in <module>\n NameError: name 'asdasd' is not defined", status: :failed }
    end
  end
end
