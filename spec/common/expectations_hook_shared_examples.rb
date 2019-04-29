shared_examples 'common python expectations hook' do
  describe 'HasTooShortIdentifiers' do
    let(:code) { "def f(x):\n\treturn g(x)" }
    let(:expectations) { [] }

    it { expect(result).to eq [{expectation: {binding: 'f', inspection: 'HasTooShortIdentifiers'}, result: false}] }
  end

  describe 'HasWrongCaseIdentifiers' do
    let(:code) { "def aFunctionWithBadCase():\n\treturn 3" }
    let(:expectations) { [] }

    it { expect(result).to eq [{expectation: {binding: 'aFunctionWithBadCase', inspection: 'HasWrongCaseIdentifiers'}, result: false}] }
  end

  describe 'HasRedundantIf' do
    let(:code) { "def foo(x):\n\tif x:\n\t\treturn True\n\telse:\n\t\treturn False\n\n" }
    let(:expectations) { [] }

    it { expect(result).to eq [{expectation: {binding: 'foo', inspection: 'HasRedundantIf'}, result: false}] }
  end

  describe 'DeclaresProcedure' do
    let(:code) { "def foo(x, y):\n\tpass\n\nbar = 4" }
    let(:expectations) { [
      {binding: '*', inspection: 'DeclaresProcedure:foo'},
      {binding: '*', inspection: 'DeclaresProcedure:bar'},
      {binding: '*', inspection: 'DeclaresProcedure:baz'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[1], result: false},
        {expectation: expectations[2], result: false}] }
  end


  describe 'DeclaresFunction' do
    let(:code) { "def foo(x, y):\n\treturn x + y\n\nbar = 4" }
    let(:expectations) { [
      {binding: '*', inspection: 'DeclaresFunction:foo'},
      {binding: '*', inspection: 'DeclaresFunction:bar'},
      {binding: '*', inspection: 'DeclaresFunction:baz'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[1], result: false},
        {expectation: expectations[2], result: false}] }
  end

  describe 'DeclaresVariable' do
    let(:code) { "def foo(x, y):\n\tpass\n\nbar = 4" }
    let(:expectations) { [
      {binding: '*', inspection: 'DeclaresVariable:foo'},
      {binding: '*', inspection: 'DeclaresVariable:bar'},
      {binding: '*', inspection: 'DeclaresVariable:baz'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: false},
        {expectation: expectations[1], result: false},
        {expectation: expectations[2], result: false}] }
  end

  describe 'Declares' do
    let(:code) { "def foo(x, y):\n\tpass\n\nbar = 4" }
    let(:expectations) { [
      {binding: '*', inspection: 'Declares:foo'},
      {binding: '*', inspection: 'Declares:bar'},
      {binding: '*', inspection: 'Declares:baz'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[1], result: false},
        {expectation: expectations[2], result: false}] }
  end

  describe 'Assigns' do
    let(:code) { "bar = 4" }
    let(:expectations) { [
      {binding: '*', inspection: 'Assigns:bar'},
      {binding: '*', inspection: 'Assigns:baz'}] }

    it { expect(result).to eq [
        {expectation: expectations[0], result: true},
        {expectation: expectations[1], result: false}] }
  end

  describe 'DoesConsolePrint' do
    let(:code) { "print('hello')" }
    let(:expectations) { [] }

    it { expect(result).to eq [{expectation: {binding: '*', inspection: 'DoesConsolePrint'}, result: false}] }
  end

  describe 'Raises' do
    let(:code) { "raise Exception('foo')" }
    let(:expectations) { [{binding: '*', inspection: 'Raises:Exception'}] }

    it { expect(result).to eq [{expectation: expectations[0], result: true}] }
  end
end
