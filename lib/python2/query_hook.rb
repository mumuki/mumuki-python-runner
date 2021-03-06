class Python2QueryHook < BasePythonQueryHook
  def compile_query(query, output_prefix = "=> ")
    if query.match /print *(\(| ).*|.*[^=><!]=[^=].*|^raise\b/
      query
    else
      <<~python
        __mumuki_error__ = None
        try:
          __mumuki_args__ = {'mumuki_query_result': eval("""#{query.gsub('"', '\"')}""")}
          print(string.Template(\"\${mumuki_query_result}\").safe_substitute(**__mumuki_args__))
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
end

PythonQueryHook = Python2QueryHook
