class TestHook < Mumukit::Templates::FileHook
  isolated true

  def command_line(filename)
    "python -m unittest #{filename} 2>&1"
  end

  def compile_file_content(request)
    <<python
import unittest

#{request.content}
#{request.extra}
#{request.test}
python
  end
end
