class Python3MetadataHook < BasePythonMetadataHook
  def self.read_xce_file(path)
    File.read(File.expand_path "../../../xce/#{path}", __FILE__)
  end

  XCE_INSTRUCTIONS = {
    'Colab': {
      'en': read_xce_file('colab/en/README.md'),
      'pt': read_xce_file('colab/pt/README.md'),
      'es': read_xce_file('colab/es-ar/README.md'),
      'es-ar': read_xce_file('colab/es-ar/README.md')
    },
    'Visual Studio Code': {
      'en': read_xce_file('visual_studio/en/README.md'),
      'pt': read_xce_file('visual_studio/pt/README.md'),
      'es': read_xce_file('visual_studio/es-ar/README.md'),
      'es-ar': read_xce_file('visual_studio/es-ar/README.md')
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
