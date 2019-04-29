class Python2MetadataHook < BasePythonMetadataHook
  def version
    '2.7.16'
  end
end

PythonMetadataHook = Python2MetadataHook

