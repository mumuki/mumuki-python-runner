shared_examples "common python test hook" do
  context 'passes when test pass' do
    let(:request) { struct(content: '
def foo():
  return 4', test: '
def test_true_is_true(self):
  self.assertTrue(True)') }
    it { expect(result[0]).to match_array [['True is true', :passed, '']] }
  end

  context 'formats special words' do
    let(:request) { struct(content: '
def foo():
  return 4', test: '
def test_foo__PL__5__DT__1__CM____QT__hello__QT____CM____DQ__bar__DQ____PR__(self):
  self.assertTrue(True)') }
    it { expect(result[0]).to match_array [['Foo(5.1,\'hello\',"bar")', :passed, '']] }
  end

  context 'fails when test fails' do
    let(:request) { struct(content: '
def foo():
  return 4', test: '
def test_true_is_false(self):
  self.assertTrue(False)') }
    it { expect(result[0]).to match_array [['True is false', :failed, 'AssertionError: False is not true']] }
  end

  context 'accepts full-defined tests' do
    let(:request) { struct(content: '
def foo():
  return 4', test: '

class MyTest(unittest.TestCase):
  def test_true(self):
    self.assertTrue(True)') }
    it { expect(result[0]).to match_array [['True', :passed, '']] }
  end

  context 'works when there are not tests' do
    let(:request) { struct(content: '
def foo():
  return 4', test: '

class MyTest(unittest.TestCase):
  pass') }
    it do
      expect(result[0]).to include 'Ran 0 tests'
      expect(result[1]).to eq :errored
    end
  end

  context 'accepts multiple tests' do
    let(:request) { struct(content: '
def foo():
  return 4', test: '
def test_false(self):
  self.assertFalse(False)

def test_true(self):
  self.assertTrue(True)') }
    it { expect(result[0]).to match_array [['False', :passed, ''], ['True', :passed, '']] }
  end

  context 'passes when test pass and there are utf8 chars' do
    let(:request) { struct(content: '
def foo():
  return "fóò"', test: '
def test_true_is_true(self):
  self.assertEqual(foo(), "fóò")') }
    it { expect(result[0]).to match_array [['True is true', :passed, '']] }
  end

  context 'loads extra before content' do
    let(:request) { struct(content: '
foo()', test: '
def test_false(self):
  self.assertFalse(False)', extra: '
def foo():
  pass') }
    it { expect(result[0]).to match_array [['False', :passed, '']] }
  end
end
