class BasePythonQueryHook < Mumukit::Templates::FileHook
  with_error_patterns
  isolated true

  def command_line(filename)
    "python #{filename} 2>&1"
  end

  def compile_file_content(req)
    "#{compile_file_header(req)}\n#{compile_query(req.query)}"
  end

  def compile_file_header(req)
    <<python
# -*- coding: UTF-8 -*-
import string, sys, os

#{req.extra}
#{req.content}
sys.stdout = open(os.devnull, 'w')
#{compile_cookie(req.cookie)}
sys.stdout = sys.__stdout__
python
  end

  def compile_query(query, output_prefix = "=> ")
    if query.match /print *(\(| ).*|.*[^=]=[^=].*|^raise\b/
      query
    else
      <<~python
        __mumuki_error__ = None
        try:
          __mumuki_args__ = {'mumuki_query_result': eval("""#{query.gsub('"', '\"')}""")}
          print(string.Template(\"#{output_prefix}\${mumuki_query_result}\").safe_substitute(**__mumuki_args__))
        except SyntaxError as e:
          __mumuki_error__ = SyntaxError(e.msg, ('<console>', e.lineno, e.offset, e.text))
        if __mumuki_error__:
          print(__mumuki_error__.text)
          print(" "*(__mumuki_error__.offset - 1) + "^")
          print('SyntheticMumukiSyntaxError: SyntaxError: ' + str(__mumuki_error__))
          exit(1)
      python
    end
  end

  def compile_state(cookie)
    (cookie||[]).map do |statement|
    <<~python
    try:
      #{statement}
    except:
      pass
python
    end
  end

  def compile_cookie(cookie)
    compile_state(cookie).join("\n")
  end

  def error_patterns
    [
      Mumukit::ErrorPattern::Errored.new(syntax_error_regexp)
    ]
  end

  def syntax_error_regexp
    /(SyntheticMumukiSyntaxError: )|(\A  File .*\n(?m)(?=.*(SyntaxError|IndentationError)))/
  end
end







