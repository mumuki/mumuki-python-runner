require 'mumukit'
require 'nokogiri'

I18n.load_translations_path File.join(__dir__, 'locales', '*.yml')

require_relative './base/version'
require_relative './base/test_hook'
require_relative './base/query_hook'
require_relative './base/metadata_hook'
