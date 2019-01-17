class PythonQueryHook < Mumukit::Templates::FileHook
  isolated true

  def command_line(filename)
    "python #{filename} 2>&1"
  end

  def compile_file_content(req)
    <<python
import string

#{req.extra}
#{req.content}
#{build_query req.query}
python
  end

  def build_query(query)
    if query.match /print *(\(| ).*/
      query
    else
      "print(string.Template(\"=> $result\").substitute(result = #{query}))"
    end
  end
end







