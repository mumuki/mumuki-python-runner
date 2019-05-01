class BasePythonExpectationsHook < Mumukit::Templates::MulangExpectationsHook
  include_smells true

  def default_smell_exceptions
    LOGIC_SMELLS + FUNCTIONAL_SMELLS
  end

  def domain_language
    {
      caseStyle: 'RubyCase',
      minimumIdentifierSize: 3,
      jargon: []
    }
  end
end
