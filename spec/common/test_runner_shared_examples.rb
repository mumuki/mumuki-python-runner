shared_examples "common python test hook" do
  context 'passes when test pass' do
    let(:request) { struct(content: '
def foo():
  return 4', test: '
def test_true_is_true(self):
  self.assertTrue(True)') }
    it { expect(result[0]).to match_array [['True is true', :passed, '']] }
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
end
