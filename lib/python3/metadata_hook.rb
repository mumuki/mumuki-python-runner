class Python3MetadataHook < BasePythonMetadataHook
  XCE_INSTRUCTIONS = {
    'Colab': {
      'en': File.read("xce/colab/en/README.md"),
      'pt': File.read("xce/colab/pt/README.md"),
      'es': File.read("xce/colab/es-ar/README.md"),
      'es-ar': File.read("xce/colab/es-ar/README.md")
    },
    'Visual Studio Code': {
      'en': File.read("xce/visual_studio/en/README.md"),
      'pt': File.read("xce/visual_studio/pt/README.md"),
      'es': File.read("xce/visual_studio/es-ar/README.md"),
      'es-ar': File.read("xce/visual_studio/es-ar/README.md")
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
