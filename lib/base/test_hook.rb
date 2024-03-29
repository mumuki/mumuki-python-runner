class BasePythonTestHook < Mumukit::Templates::FileHook
  isolated true
  line_number_offset 8, include_extra: true

  def tempfile_extension
    '.py'
  end

  def command_line(filename)
    "rununittest #{filename}"
  end

  def compile_file_content(request)
    <<python
# -*- coding: UTF-8 -*-

import unittest
import xmlrunner
import sys
from datetime import datetime, date

#{request.extra}
#{request.content}
#{test_class(request.test)}

unittest.main(
  testRunner=xmlrunner.XMLTestRunner(output='./xml-unittest-output'),
  failfast=False,
  buffer=False,
  catchbreak=False
)
python
  end

  def post_process_file(_file, output, status)
    xml = output.split("Generating XML reports...\n").last
    raise StandardError, 'No XML found' unless xml.start_with? '<?xml'

    [generate_test_results(Nokogiri::XML(xml))]
  rescue
    [output, :errored]
  end

  def line_number_reference_regexp
    /"#{masked_tempfile_path}", line (\d+)/m
  end

  def rebuild_line_number_reference(new_line_number)
    "\"#{masked_tempfile_path}\", line #{new_line_number}"
  end

  private

  def test_class(test)
    return test if test =~ /class.*\( *unittest.TestCase *\) *:/
    <<python
class MumukiTest(unittest.TestCase):
  #{test.gsub(/\n/,"\n\t")}
python
  end

  def generate_test_results(report)
    report.xpath('//testcase').map(&method(:test_result))
  end

  def test_result(test_case)
    failure = test_case.xpath('failure', 'error')
    error = failure.attribute('type')
    message = failure.attribute('message')
    assertion_error_message = try_extract_assertion_error(failure)

    [
        format_test_name(test_case.attribute('name').to_s),
        error.nil? ? :passed: :failed,
        error.nil? ? '' : "#{error}: #{assertion_error_message || message}"
    ]
  end

  def try_extract_assertion_error(failure)
    failure.text.split("AssertionError: ")[1]&.rstrip.try do |it|
      it.each_line.count > 1 ? it + "\n" : it
    end
  end

  def format_test_name(name)
    name
      .sub('test_', '')
      .gsub('__PL__', '(')
      .gsub('__PR__', ')')
      .gsub('__DT__', '.')
      .gsub('__CM__', ',')
      .gsub('__QT__', '\'')
      .gsub('__DQ__', '"')
      .gsub('_', ' ')
      .capitalize
  end
end
