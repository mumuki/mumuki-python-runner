class Python3QueryHook < BasePythonQueryHook
  def compile_query(query, output_prefix = "=> ")
    <<~python
      import code
      import itertools
      import traceback
      import sys

      __mumuki_console__ = code.InteractiveConsole()

      try:
        __mumuki_result__ = __mumuki_console__.compile("""#{query.gsub('"', '\"')}""")
        if __mumuki_result__ != None:
          exec(__mumuki_result__)
        else:
          raise SyntaxError('unexpected EOF while parsing')
      except:
        error = sys.exc_info()
        stack = traceback.format_exception(*error)
        print(*itertools.dropwhile(lambda it: 'File "<input>"' not in it, stack))
        exit(1)
    python
  end
end
