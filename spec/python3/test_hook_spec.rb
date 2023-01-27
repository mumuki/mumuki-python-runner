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
                                              ['Ruby is python', :failed, "AssertionError: 'ruby' != 'python'\n- ruby\n+ python\n"],
                                              ['True is true', :passed, ''],
                                              ['False is true', :failed, 'AssertionError: False is not true'],
                                          ] }
  end


  context 'properly displays complex string comparisons' do
    let(:request) { struct(content: '
def greet():
  return "hello world"', test: '
def test_greet_is_hello(self):
  self.assertEqual(greet(), "hello")') }

    it { expect(result[0]).to match_array [[
      "Greet is hello",
      :failed,
      <<~EOM
      AssertionError: 'hello world' != 'hello'
      - hello world
      + hello
      EOM
      ]] }
  end

  context 'properly displays complex string comparisons with whitespaces' do
    let(:request) { struct(content: '
def greet():
  return "hello "', test: '
def test_greet_is_hello(self):
  self.assertEqual(greet(), "hello")') }

    it { expect(result[0]).to match_array [[
      "Greet is hello",
      :failed,
      <<~EOM
      AssertionError: 'hello ' != 'hello'
      - hello\s
      ?      -
      + hello
      EOM
      ]] }
  end

  context 'properly displays complex list comparisons' do
    let(:request) { struct(content: '
def numbers():
  return [1, 2, 5, 8]', test: '
def test_numbers_is_a_list(self):
  self.assertEqual(numbers(), [1, 2, 4, 5, 6, 7, 8])') }

    it { expect(result[0]).to match_array [[
      "Numbers is a list",
      :failed,
      <<~EOM
      AssertionError: Lists differ: [1, 2, 5, 8] != [1, 2, 4, 5, 6, 7, 8]

      First differing element 2:
      5
      4

      Second list contains 3 additional elements.
      First extra element 4:
      6

      - [1, 2, 5, 8]
      + [1, 2, 4, 5, 6, 7, 8]
      EOM
      ]] }
  end

  context 'properly displays complex dict comparisons' do
    let(:request) { struct(content: '
def person():
  return {"age":25}', test: '
def test_person_is_a_dict(self):
  self.assertEqual(person(), {"name":"Umi", "age":28})') }

    it { expect(result[0]).to match_array [[
      "Person is a dict",
      :failed,
      <<~EOM
      AssertionError: {'age': 25} != {'name': 'Umi', 'age': 28}
      - {'age': 25}
      + {'age': 28, 'name': 'Umi'}
      EOM
      ]] }
  end

  context 'properly displays complex dict comparisons with newlines inside' do
    let(:request) do
      struct(
        content: <<~EOM,
        def person():
          return {"name": "Umi\\n", "age":28}
        EOM
        test: <<~EOM
        def test_person_is_a_dict(self):
          self.assertEqual(person(), {"name":"Umi", "age":28})
        EOM
      )
    end

    it do
      expect(result[0]).to match_array [[
        "Person is a dict",
        :failed,
        <<~EOM
        AssertionError: {'name': 'Umi\\n', 'age': 28} != {'name': 'Umi', 'age': 28}
        - {'age': 28, 'name': 'Umi\\n'}
        ?                         --

        + {'age': 28, 'name': 'Umi'}
        EOM
      ]]
    end
  end
end