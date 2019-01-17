require 'mumukit'

I18n.load_translations_path File.join(__dir__, 'locales', '*.yml')

Mumukit.runner_name = 'python'
Mumukit.configure do |config|
  config.docker_image = 'mumuki/mumuki-python-worker'
end

require_relative 'version'
require_relative 'test_hook'
require_relative 'query_hook'
require_relative 'metadata_hook'


