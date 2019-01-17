class PythonTestHook < Mumukit::Templates::FileHook
  isolated true

  def tempfile_extension
    '.py'
  end

  def command_line(filename)
    "python #{filename}"
  end

  def compile_file_content(request)
    <<python
import unittest

#{request.content}
#{request.extra}
#{test_class(request.test)}


unittest.main()
python
  end

  def test_class(test)
    return test if test =~ /class.*\( *unittest.TestCase *\) *:/
    <<python
class MumukiTest(unittest.TestCase):
  #{test.gsub(/\n/,"\n\t")}
python
  end
end

