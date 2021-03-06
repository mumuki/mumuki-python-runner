shared_examples "common python query hook" do
  context 'passes when standalone query is valid.' do
    let(:request) { struct query: '4 + 5' }
    it { expect(result).to eq ["9\n", :passed] }
  end

  context 'passes when standalone query fails.' do
    let(:request) { struct query: '0 / 0' }
    it { expect(result).to eq ["  File \"<input>\", line 1, in <module>\n ZeroDivisionError: division by zero\n\n", :failed] }
  end

  context 'passes when query is a single print' do
    let(:request) { struct query: 'print("hello")' }
    it { expect(result).to eq ["hello\n", :passed] }
  end

  context 'fails when query is a broken print' do
    let(:request) { struct query: 'print("hello"' }
    it { expect(result).to eq :errored }
  end

  context 'passes when query and content is valid.' do
    let(:request) { struct query: '4 + x', content: 'x = 10' }
    it { expect(result).to eq ["14\n", :passed] }
  end

  context 'passes when query is an == comparison' do
    let(:request) { struct query: '123 == 123' }
    it { expect(result).to eq ["True\n", :passed] }
  end

  context 'passes when query is an > comparison' do
    let(:request) { struct query: '123 > 123' }
    it { expect(result).to eq ["False\n", :passed] }
  end

  context 'passes when query is an <= comparison' do
    let(:request) { struct query: '123 <= 123' }
    it { expect(result).to eq ["True\n", :passed] }
  end

  context 'passes when query is an != comparison' do
    let(:request) { struct query: '123 != 123' }
    it { expect(result).to eq ["False\n", :passed] }
  end

  context 'passes when query is an >= comparison' do
    let(:request) { struct query: '123 >= 123' }
    it { expect(result).to eq ["True\n", :passed] }
  end

  context 'passes when query is an assignment' do
    let(:request) { struct query: 'foo = 123' }
    it { expect(result).to eq ["", :passed] }
  end

  context 'passes when query is an assignment to an object' do
    let(:request) { struct query: "x.a = 123", cookie: ['class X: pass', 'x = X()'] }
    it { expect(result).to eq ["", :passed] }
  end

  context 'passes when query is an assignment to a list' do
    let(:request) { struct query: "x[1] = 123", cookie: ['x = [1, 3, 8]'] }
    it { expect(result).to eq ["", :passed] }
  end

  context 'passes when query is an assignment with increment' do
    let(:request) { struct query: "x += 123", cookie: ['x = 0'] }
    it { expect(result).to eq ["", :passed] }
  end


  context 'passes when query is an assignment to a dict' do
    let(:request) { struct query: "x['a'] = 123", cookie: ['x = {}'] }
    it { expect(result).to eq ["", :passed] }
  end

  context 'properly replaces variables when result is number' do
    let(:request) { struct query: 'x', cookie: ['x = 4'] }
    it { expect(result).to eq ["4\n", :passed] }
  end

  context 'properly replaces variables when result is boolean' do
    let(:request) { struct query: 'x == 4', cookie: ['x = 4'] }
    it { expect(result).to eq ["True\n", :passed] }
  end

  context 'is stateful' do
    let(:request) { struct query: 'print(foo)', cookie: ['foo = 123'] }
    it { expect(result).to eq ["123\n", :passed] }
  end

  context 'does not redo prints in cookie' do
    let(:request) { struct query: 'print("foo")', cookie: ['print("bar")'] }
    it { expect(result).to eq ["foo\n", :passed] }
  end

  context 'does not fail if an exception was thrown in cookie' do
    let(:request) { struct query: 'print("foo")', cookie: ['raise(Exception("bar"))'] }
    it { expect(result).to eq ["foo\n", :passed] }
  end

  context 'responds with errored when query has a syntax error' do
    let(:request) { struct query: '!' }
    it { expect(result[0]).to eq %Q{!\n^\nSyntaxError: unexpected EOF while parsing (<console>, line 1)} }
    it { expect(result[1]).to eq :errored }
  end

  context 'responds with errored when query has an indentation error' do
    let(:request) { struct query: ' print("123")' }
    it { expect(result[0]).to eq %q{print("123")
    ^
IndentationError: unexpected indent} }
    it { expect(result[1]).to eq :errored }
  end
end
