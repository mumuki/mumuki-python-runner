class MetadataHook < Mumukit::Hook
  def metadata
    {language: {
        name: 'python',
        icon: {type: 'devicon', name: 'python'},
        version: '3.5',
        extension: 'py',
        ace_mode: 'python'
    },
     test_framework: {
         name: 'unittest',
         test_extension: 'py'
     }}
  end
end