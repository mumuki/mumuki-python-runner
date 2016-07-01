class QueryHook < Mumukit::Templates::FileHook
  isolated true

  def command_line(filename)
    "python #{filename} 2>&1"
  end

  def compile_file_content(req)
    <<python
import string

#{req.extra}
#{req.content}

print(string.Template("=> $result").substitute(result = #{req.query}))
python
  end

end







