class Python3MetadataHook < BasePythonMetadataHook
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
end
