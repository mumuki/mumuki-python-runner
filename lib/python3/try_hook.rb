class Python3TryHook < Mumukit::Templates::TryHook
  isolated true

  def initialize(config = nil)
    super config
    @query_hook = Python3QueryHook.new
  end

  def compile_file_content(r)
    <<python
#{@query_hook.compile_file_header(r)}
print("#{query_separator}");
#{@query_hook.compile_query(r.query, '')}
print("#{goal_separator}");
#{@query_hook.compile_query(r.goal.indifferent_get(:query) || 'None', '')}
python
  end

  delegate :tempfile_extension, to: :@query_hook
  delegate :command_line, to: :@query_hook

  def post_process_file(file, result, status)
    super file, *@query_hook.post_process_file(file, result, status)
  end

  def query_separator
    '!!!MUMUKI-QUERY-START!!!'
  end

  def goal_separator
    '!!!MUMUKI-GOAL-START!!!'
  end

  def to_structured_results(_file, result, status)
    result_match = result[/#{query_separator}
\K.*?(?=(#{goal_separator})|\z)/m]&.rstrip
    goal_match = result[/#{goal_separator}
\K.*\z/m]&.rstrip

    {
        query: to_query_result(result_match, status),
        goal: goal_match,
        status: status
    }
  end

  def to_query_result(result, status)
    { result: result, status: status }
  end

  def checker_options
    { strip_mode: :right_only }
  end

end
