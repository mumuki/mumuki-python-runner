require_relative './spec_helper'

describe Python3TestHook do
  before(:all) { reload_python3_runner! }

  let(:hook) { Python3TestHook.new }
  let!(:result) { hook.run!(hook.compile(request)) }

  it_behaves_like 'common python test hook'

  context 'fails when some test pass and other fail' do
    let(:request) { struct(content: '
def foo():
  return 4', test: '
def test_ruby_is_python(self):
  self.assertEquals("ruby", "python")
def test_true_is_true(self):
  self.assertTrue(True)
def test_false_is_true(self):
  self.assertTrue(False)
') }
    it { expect(result[0]).to match_array [
                                              ['Ruby is python', :failed, "AssertionError: 'ruby' != 'python' - ruby + python "],
                                              ['True is true', :passed, ''],
                                              ['False is true', :failed, 'AssertionError: False is not true'],
                                          ] }
  end
end
