require_relative 'spec_helper'

describe PythonTestHook do
  let(:hook) { PythonTestHook.new }
  let(:file) { hook.compile(request) }
  let!(:result) { hook.run!(file) }

  context 'passes when test pass' do
    let(:request) { OpenStruct.new(content: '
def foo():
    return 4', test: '
class TestFoo(unittest.TestCase):
    def test_true(self):
        self.assertTrue(True)
') }
    it { expect(result[1]).to eq :passed }
  end

  context 'fails when test fails' do
    let(:request) { OpenStruct.new(content: '
def foo():
    return 4', test: '
class TestFoo(unittest.TestCase):
    def test_true(self):
        self.assertTrue(False)
') }
    it { expect(result[1]).to eq :failed }
  end
end
