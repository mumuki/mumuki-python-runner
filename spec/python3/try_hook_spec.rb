require_relative './spec_helper'
require 'ostruct'

describe Python3TryHook do
  let(:hook) { Python3TryHook.new }
  let(:file) { hook.compile(request) }
  let(:result) { hook.run!(file) }

  context 'try with last_query_equals goal' do
    let(:goal) { { kind: 'last_query_equals', value: '"something"' } }

    context 'and query that matches' do
      let(:request) { struct query: '"something"', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq "'something'" }
    end

    context 'and query that does not match' do
      let(:request) { struct query: '"somethingElse"', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq "'somethingElse'" }
    end
  end

  context 'try with last_query_matches goal' do
    let(:goal) { { kind: 'last_query_matches', regexp: /print(.*)/ } }

    context 'and query that matches' do
      let(:request) { struct query: 'print(3)', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '3' }
    end

    context 'and query that does not match' do
      let(:request) { struct query: 'abs(2)', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq '2' }
    end
  end

  context 'try with last_query_matches goal, with string' do
    let(:goal) { { kind: 'last_query_matches', regexp: 'print(.*)' } }

    context 'and query that matches' do
      let(:request) { struct query: 'print(3)', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '3' }
    end

    context 'and query that does not match' do
      let(:request) { struct query: 'abs(2)', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq '2' }
    end
  end

  context 'try with last_query_matches goal, with =' do
    let(:goal) { { kind: 'last_query_matches', regexp: '4\W+!=\W+5' } }

    context 'and query that matches' do
      let(:request) { struct query: '4  !=  5  ', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq 'True' }
    end

    context 'and query that does not match' do
      let(:request) { struct query: '  4 != 4', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq 'False' }
    end
  end


  context 'try with last_query_matches goal, with <' do
    let(:goal) { { kind: 'last_query_matches', regexp: '4\W+<\W+5' } }

    context 'and query that matches' do
      let(:request) { struct query: '4  <  5  ', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq 'True' }
    end

    context 'and query that does not match' do
      let(:request) { struct query: '  4 < 4', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq 'False' }
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

    context 'and query that makes said query pass' do
      let(:request) { struct query: 'my_var = 2;', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq '' }
    end

    context 'and query that does not make said query pass' do
      let(:request) { struct query: '', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '' }
    end
  end

  context 'try with query_passes goal' do
    let(:goal) { { kind: 'query_passes', query: 'my_var' } }

    context 'and query that makes said query pass' do
      let(:request) { struct query: 'my_var = 2;', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '' }
    end

    context 'and query that does not make said query pass' do
      let(:request) { struct query: '', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq '' }
    end
  end

  context 'try with query_outputs goal' do
    let(:goal) { { kind: 'query_outputs', query: 'my_var', output: '55' } }

    context 'and query that generates said output' do
      let(:request) { struct query: 'my_var = 55;', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '' }
    end

    context 'and query that does not generate said output' do
      let(:request) { struct query: 'my_var = 28', goal: goal }
      it { expect(result[1]).to eq :failed }
      it { expect(result[2][:result]).to eq '' }
    end
  end

  context 'try with last_query_passes goal' do
    let(:goal) { { kind: 'last_query_passes' } }

    context 'and query that passes' do
      let(:request) { struct query: '123', goal: goal }
      it { expect(result[1]).to eq :passed }
      it { expect(result[2][:result]).to eq '123' }
    end

    context 'and query that fails' do
      let(:request) { struct query: 'asdasd', goal: goal }
      it { expect(result[1]).to eq :failed }
      pending { expect(result[2]).to eq result: "Reference error", status: :failed }
    end
  end
end
