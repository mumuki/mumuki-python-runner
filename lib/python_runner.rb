require 'i18n'

I18n.load_path += Dir[File.join('.', 'locales', '*.yml')]

require 'mumukit'

Mumukit.runner_name = 'python'
Mumukit.configure do |config|
  config.docker_image = 'mumuki/mumuki-python-worker'
end

require_relative 'test_hook'
require_relative 'query_hook'
require_relative 'metadata_hook'


