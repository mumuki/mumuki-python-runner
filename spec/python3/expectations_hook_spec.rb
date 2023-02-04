require_relative './spec_helper'

describe Python3ExpectationsHook do
  let(:runner) { Python3ExpectationsHook.new }
  let(:result) { runner.run!(runner.compile(struct(expectations: expectations, content: code))) }

  it_behaves_like 'common python expectations hook'

  describe 'DoesConsolePrint' do
    let(:expectations) { [] }

    context 'with args' do
      let(:code) { "print('foo', 1, 'bar', 2)" }
      it { expect(result).to eq [{expectation: {binding: '*', inspection: 'DoesConsolePrint'}, result: false}] }
    end

    context 'without' do
      let(:code) { "print()" }
      it { expect(result).to eq [{expectation: {binding: '*', inspection: 'DoesConsolePrint'}, result: false}] }
    end

  end

  describe 'UsesSetAt' do
    let(:code) do
      "def clear_at(x):\n\tx['a'] = 0"
    end
    let(:expectations) { [
      {binding: 'clear_at', inspection: 'UsesSetAt'},
      {binding: 'clear_at', inspection: 'UsesGetAt'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[1], result: false}] }
  end

  describe 'UsesSize' do
    let(:code) do
      "def count(x):\n\treturn len(x)"
    end
    let(:expectations) { [
      {binding: 'count', inspection: 'UsesSize'},
      {binding: 'count', inspection: 'Uses:len'},
      {binding: 'count', inspection: 'UsesSetAt'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[0], result: true},
        {expectation: expectations[2], result: false}] }
  end

  describe 'UsesGetAt' do
    let(:code) do
      "def first(x):\n\treturn x[0]"
    end
    let(:expectations) { [
      {binding: 'first', inspection: 'UsesGetAt'},
      {binding: 'first', inspection: 'Uses:[]'},
      {binding: 'first', inspection: 'UsesSlice'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[0], result: true},
        {expectation: expectations[2], result: false}] }
  end

  describe 'UsesSlice' do
    let(:code) do
      "def last_2(x):\n\treturn x[-2:]"
    end
    let(:expectations) { [
      {binding: 'last_2', inspection: 'UsesSlice'},
      {binding: 'last_2', inspection: 'UsesGetAt'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[1], result: false}] }
  end

  describe 'UsesComprehension' do
    let(:code) do
      <<~EOC
      def map_plus_one(xs):
        return (x + 1 for x in xs)

      def map_plus_two(xs):
        return [x + 2 for x in xs]

      def map_plus_three(xs):
        result = []
        for x in xs:
          result.append(x + 4)
        return result
      EOC
    end
    let(:expectations) { [
      {binding: 'map_plus_one', inspection: 'UsesComprehension'},
      {binding: 'map_plus_two', inspection: 'UsesComprehension'},
      {binding: 'map_plus_four', inspection: 'UsesComprehension'},
    ] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[1], result: true},
        {expectation: expectations[2], result: false}] }
  end


end
