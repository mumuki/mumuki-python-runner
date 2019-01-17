require_relative 'spec_helper'

describe PythonTestHook do
  let(:hook) { PythonTestHook.new }
  let(:file) { hook.compile(request) }
  let!(:result) { hook.run!(file) }

  context 'passes when test pass' do
    let(:request) { OpenStruct.new(content: '
def foo():
  return 4', test: '
def test_true_is_true(self):
  self.assertTrue(True)') }
    it { expect(result[0]).to match_array [['True is true', :passed, '']] }
  end

  context 'fails when test fails' do
    let(:request) { OpenStruct.new(content: '
def foo():
  return 4', test: '
def test_true_is_false(self):
  self.assertTrue(False)') }
    it { expect(result[0]).to match_array [['True is false', :failed, 'AssertionError: False is not true']] }
  end

  context 'fails when some test pass and other fail' do
    let(:request) { OpenStruct.new(content: '
def foo():
  return 4', test: '
def test_ruby_is_python(self):
  self.assertEquals("ruby", "python")
def test_true_is_true(self):
  self.assertTrue(True)
def test_false_is_true(self):
  self.assertTrue(False, True)
') }
    it { expect(result[0]).to match_array [
                                              ['Ruby is python', :failed, "AssertionError: 'ruby' != 'python'"],
                                              ['True is true', :passed, ''],
                                              ['False is true', :failed, 'AssertionError: True'],
                                          ] }
  end

  context 'accepts full-defined tests' do
    let(:request) { OpenStruct.new(content: '
def foo():
  return 4', test: '

class MyTest(unittest.TestCase):
  def test_true(self):
    self.assertTrue(True)') }
    it { expect(result[1]).to eq :passed }
    it { expect(result[0]).to eq ".\n----------------------------------------------------------------------\nRan 1 test in 0.000s\n\nOK\n" }
  end

  context 'accepts multiple tests' do
    let(:request) { OpenStruct.new(content: '
def foo():
  return 4', test: '
def test_false(self):
  self.assertFalse(False)

def test_true(self):
  self.assertTrue(True)') }
    it { expect(result[1]).to eq :passed }
    it { expect(result[0]).to eq "..\n----------------------------------------------------------------------\nRan 2 tests in 0.000s\n\nOK\n" }
  end
end
