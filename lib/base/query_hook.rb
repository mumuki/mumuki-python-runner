class BasePythonQueryHook < Mumukit::Templates::FileHook
  with_error_patterns
  isolated true

  def command_line(filename)
    "python #{filename} 2>&1"
  end

  def compile_file_content(req)
    <<python
# -*- coding: UTF-8 -*-
import string, sys, os

#{req.extra}
#{req.content}
sys.stdout = open(os.devnull, 'w')
#{compile_cookie(req.cookie)}
sys.stdout = sys.__stdout__
#{build_query req.query}
python
  end

  def build_query(query)
    if query.match /print *(\(| ).*|^[a-zA-Z_]\w*\s*=.*|^raise\b/
      query
    else
      "print(string.Template(\"=> $result\").substitute(result = #{query}))"
    end
  end

  def build_state(cookie)
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
    build_state(cookie).join("\n")
  end

  def error_patterns
    [
      Mumukit::ErrorPattern::Errored.new(syntax_error_regexp)
    ]
  end

  def syntax_error_regexp
    /\A  File .*\n(?m)(?=.*(SyntaxError|IndentationError))/
  end
end







