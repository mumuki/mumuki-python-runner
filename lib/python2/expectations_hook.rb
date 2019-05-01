class Python2ExpectationsHook < BasePythonExpectationsHook
  def language
    'Python2'
  end
end

PythonExpectationsHook = Python2ExpectationsHook
