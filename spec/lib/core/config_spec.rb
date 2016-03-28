require 'core/config'

RSpec.describe PatchFinder::Config do

  let(:doc_directory) do
    '/docs/bin'
  end

  let(:root_directory) do
    '/lib'
  end

  describe 'self.doc_directory' do
    it 'returns the doc directory path' do
      expect(PatchFinder::Config.doc_directory).to include(doc_directory)
    end
  end

  describe 'self.root_directory' do
    it 'returns the root directory path' do
      expect(PatchFinder::Config.root_directory).to include(root_directory)
    end
  end

end
