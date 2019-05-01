require_relative './spec_helper'

describe Python3ExpectationsHook do
  let(:runner) { Python3ExpectationsHook.new }
  let(:result) { runner.run!(runner.compile(struct(expectations: expectations, content: code))) }

  it_behaves_like 'common python expectations hook'
end
