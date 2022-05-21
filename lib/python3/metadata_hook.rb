class Python3MetadataHook < BasePythonMetadataHook
  def version
    '3.7.3'
  end

  def libraries
    {pandas: '1.3.3'}
  end
end
