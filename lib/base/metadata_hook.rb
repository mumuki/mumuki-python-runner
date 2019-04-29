class BasePythonMetadataHook < Mumukit::Hook
  def metadata
    {language: {
        name: 'python',
        icon: {type: 'devicon', name: 'python'},
        version: version,
        extension: 'py',
        ace_mode: 'python'
    },
     test_framework: {
         name: 'unittest',
         test_extension: 'py',
         template: <<python
class Test(unittest.TestCase):

  def test_description_example(self):
    self.assertTrue(True)
python
     }}
  end

  required :version
end
