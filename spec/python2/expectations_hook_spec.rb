require_relative './spec_helper'

describe Python2ExpectationsHook do
  let(:runner) { Python2ExpectationsHook.new }
  let(:result) { runner.run!(runner.compile(struct(expectations: expectations, content: code))) }

  it_behaves_like 'common python expectations hook'

  describe 'DoesConsolePrint with version-2 style' do
    let(:code) { "print 'hello'" }
    let(:expectations) { [] }

    it { expect(result).to eq [{expectation: {binding: '*', inspection: 'DoesConsolePrint'}, result: false}] }
  end

  describe 'Raises with version-2 style' do
    let(:code) { "raise Exception, 'foo'" }
    let(:expectations) { [{binding: '*', inspection: 'Raises:Exception'}] }

    it { expect(result).to eq [{expectation: expectations[0], result: true}] }
  end

end
