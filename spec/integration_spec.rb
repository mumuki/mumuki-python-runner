require_relative '../lib/python_runner'
require 'mumukit/bridge'

describe 'python integration test' do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://localhost:4567') }

  before(:all) do
    @pid = Process.spawn 'rackup -p 4567', err: '/dev/null'
    sleep 3
  end
  after(:all) { Process.kill 'TERM', @pid }

  it 'start python2 by default' do
    expect(bridge.info['language']).to include('version' => '2.7.16')
  end
end
