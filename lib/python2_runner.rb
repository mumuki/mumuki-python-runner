require_relative './base'

def reload_python2_runner!
  Mumukit.runner_name = 'python'
  Mumukit.configure do |config|
    config.docker_image = 'mumuki/mumuki-python2-worker:0.1'
    # comment type should be Mumukit::Directives::CommentType::Ruby, but it is
    # Mumukit::Directives::CommentType::Cpp for backward compatibility
    config.stateful = true
    config.structured = true
  end
end

# for testing only
reload_python2_runner!

require_relative './python2/version'
require_relative './python2/test_hook'
require_relative './python2/query_hook'
require_relative './python2/expectations_hook'
require_relative './python2/metadata_hook'
