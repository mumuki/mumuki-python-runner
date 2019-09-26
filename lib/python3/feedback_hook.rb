class Python3FeedbackHook < Mumukit::Hook
  def run!(request, results)
    test_results = results.test_results[0]

    Python3Explainer.new.explain(request.content, test_results) if test_results.is_a? String
  end

  class Python3Explainer < Mumukit::Explainer

    def explain_indentation_before_start(_, result)
      (/IndentationError: unexpected indent/.match result).try do |it|
        {type: it[1], target: it[2], near: it[3]}
      end
    end

    def explain_missing_indentation(_, result)
      (/IndentationError: expected an indented block/.match result).try do |it|
        {type: it[1], target: it[2], near: it[3]}
      end
    end

    def explain_inconsistent_indentation(_, result)
      (/IndentationError: unindent does not match any outer indentation level/.match result).try do |it|
        {type: it[1], target: it[2], near: it[3]}
      end
    end

  end
end
