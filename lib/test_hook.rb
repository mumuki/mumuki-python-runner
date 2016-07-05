class TestHook < Mumukit::Templates::FileHook
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
#{request.test}

unittest.main()
python
  end
end

