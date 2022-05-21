class Python3MetadataHook < BasePythonMetadataHook
  XCE_INSTRUCTIONS = {
    'Jupyter': {
      'en': File.read("xce/jupyter/en/README.md"),
      'es-ar': File.read("xce/jupyter/es-ar/README.md"),
    },
    'Visual Studio Code': {
      'en': File.read("xce/visual_studio/en/README.md"),
      'es-ar': File.read("xce/visual_studio/es-ar/README.md"),
    }
  }

  def version
    '3.7.3'
  end

  def libraries
    {
      pandas: '1.3.3',
      matplotlib: '3.5.3',
      seaborn: '0.12.0'
    }
  end

  def external_editor_instructions
    XCE_INSTRUCTIONS
  end
end
