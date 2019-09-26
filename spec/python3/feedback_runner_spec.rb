require_relative 'spec_helper'

def req(content, test='')
  struct content: content, test: test
end

describe Python3FeedbackHook do

  before {I18n.locale = :es}

  let(:server) {Python3TestHook.new}
  let!(:test_results) {server.run!(server.compile(request))}
  let(:feedback) {Python3FeedbackHook.new.run!(request, struct(test_results: test_results))}

  context 'unexpected indent in code' do
    let(:request) {req(%q{
  def plus_one(x):
    return x + 1
    })}
    it {expect(feedback).to include('* Uno o más argumentos están mal al invocar a `foo(long int)`. Revisá en esta parte `foo(1L);` con qué argumentos la estas llamando.')}
  end


  context 'unindented code' do
    let(:request) {req(%q{
def plus_one(x):
return x + 1
    })}
    it {expect(feedback).to include('* Uno o más argumentos están mal al invocar a `foo(long int)`. Revisá en esta parte `foo(1L);` con qué argumentos la estas llamando.')}
  end

  context 'improperly indented code' do
    let(:request) {req(%q{
def absolute(x):
  if x > 0:
    return x
   else:
    return -x
    })}
    it {expect(feedback).to include('* Uno o más argumentos están mal al invocar a `foo(long int)`. Revisá en esta parte `foo(1L);` con qué argumentos la estas llamando.')}
  end

  context 'missing : in definition' do
    let(:request) {req(%q{
def absolute(x)
  if x > 0:
    return x
  else:
    return -x
    })}
    it {expect(feedback).to include('* Uno o más argumentos están mal al invocar a `foo(long int)`. Revisá en esta parte `foo(1L);` con qué argumentos la estas llamando.')}
  end

  context 'missing : in if' do
    let(:request) {req(%q{
def absolute(x):
if x > 0
  return x
else:
  return -x
    })}
    it {expect(feedback).to include('* Uno o más argumentos están mal al invocar a `foo(long int)`. Revisá en esta parte `foo(1L);` con qué argumentos la estas llamando.')}
  end

end
