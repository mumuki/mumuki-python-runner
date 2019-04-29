require_relative './base'

def reload_python3_runner!
  Mumukit.runner_name = 'python3'
  Mumukit.configure do |config|
    config.docker_image = 'mumuki/mumuki-python3-worker:0.1'
    config.stateful = true
  end
end

# for testing only
reload_python3_runner!

require_relative './python3/version'
require_relative './python3/test_hook'
require_relative './python3/query_hook'
require_relative './python3/expectations_hook'
require_relative './python3/metadata_hook'
