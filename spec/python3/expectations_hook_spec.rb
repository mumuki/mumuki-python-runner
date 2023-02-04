require_relative './spec_helper'

describe Python3ExpectationsHook do
  let(:runner) { Python3ExpectationsHook.new }
  let(:result) { runner.run!(runner.compile(struct(expectations: expectations, custom_expectations: custom_expectations, content: code))) }
  let(:custom_expectations) { nil }

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
          result.append(x + 3)
        return result

      def map_plus_four(xs):
        for x in xs:
          yield x + 4
      EOC
    end
    let(:expectations) { [
      {binding: 'map_plus_one', inspection: 'UsesComprehension'},
      {binding: 'map_plus_two', inspection: 'UsesComprehension'},
      {binding: 'map_plus_three', inspection: 'UsesComprehension'},
    ] }

    let(:custom_expectations) do
      <<~EOC
      expectation "map_plus_one uses a list comprehension": within `map_plus_one` calls `list` with something that (uses comprehension);
      expectation "map_plus_two uses a list comprehension": within `map_plus_two` calls `list` with something that (uses comprehension);

      expectation "map_plus_four returns a comprehension": within `map_plus_four` returns with something that (uses comprehension);
      expectation "map_plus_four uses a comprehension": within `map_plus_four` uses comprehension;
      EOC
    end

    it do
      expect(result.pluck(:result)).to eq [
        true,
        true,
        false,

        false,
        true,

        false,
        true
      ]
    end
  end


end
