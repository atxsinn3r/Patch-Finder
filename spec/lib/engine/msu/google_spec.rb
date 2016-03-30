require 'patch_finder/core/helper'
require 'patch_finder/engine/msu/google'

RSpec.describe PatchFinder::Engine::MSU::Google do
  let(:json_data) do
    json = %Q|{
 "kind": "customsearch#search",
 "url": {
  "type": "application/json",
  "template": ""
 },
 "queries": {
  "request": [
   {
    "title": "Google Custom Search - internet",
    "totalResults": "1",
    "searchTerms": "internet",
    "count": 10,
    "startIndex": 1,
    "inputEncoding": "utf8",
    "outputEncoding": "utf8",
    "safe": "off",
    "cx": ""
   }
  ]
 },
 "context": {
  "title": "Technet.microsoft"
 },
 "searchInformation": {
  "searchTime": 0.413407,
  "formattedSearchTime": "0.41",
  "totalResults": "1",
  "formattedTotalResults": "1"
 },
 "items": [
  {
   "kind": "customsearch#result",
   "title": "Microsoft Security Bulletin MS15-093 - Critical",
   "htmlTitle": "Microsoft Security Bulletin MS15-093 - Critical",
   "link": "https://technet.microsoft.com/en-us/library/security/ms15-093.aspx",
   "displayLink": "technet.microsoft.com",
   "snippet": "",
   "htmlSnippet": "",
   "cacheId": "2xDJB6zqL_sJ",
   "formattedUrl": "https://technet.microsoft.com/en-us/library/security/ms15-093.aspx",
   "htmlFormattedUrl": "https://technet.microsoft.com/en-us/library/security/ms15-093.aspx",
   "pagemap": {
    "metatags": [
     {
      "search.mshkeyworda": "ms15-093",
      "search.mshattr.assetid": "ms15-093",
      "search.mshattr.docset": "bulletin",
      "search.mshattr.sarticletype": "bulletin",
      "search.mshattr.sarticleid": "MS15-093",
      "search.mshattr.sarticletitle": "Security Update for Internet Explorer",
      "search.mshattr.sarticledate": "2015-08-20",
      "search.mshattr.sarticleseverity": "Critical",
      "search.mshattr.sarticleversion": "1.1",
      "search.mshattr.sarticlerevisionnote": "",
      "search.mshattr.sarticleseosummary": "",
      "search.mshattr.skbnumber": "3088903",
      "search.mshattr.prefix": "MSRC",
      "search.mshattr.topictype": "kbOrient",
      "search.mshattr.preferredlib": "/library/security",
      "search.mshattr.preferredsitename": "TechNet",
      "search.mshattr.docsettitle": "MSRC Document",
      "search.mshattr.docsetroot": "Mt404691",
      "search.save": "history",
      "search.microsoft.help.id": "ms15-093",
      "search.description": "",
      "search.mscategory": "dn567670",
      "search.mscategoryv": "dn567670Security10",
      "search.tocnodeid": "mt404691",
      "mshkeyworda": "ms15-093",
      "mshattr": "AssetID:ms15-093",
      "save": "history",
      "microsoft.help.id": "ms15-093"
     }
    ]
   }
  }
 ]
}
        |


    r = double('Net::HTTPOK')
    allow(r).to receive(:http_version).and_return('1.1')
    allow(r).to receive(:code).and_return(200)
    allow(r).to receive(:message).and_return('OK')
    allow(r).to receive(:body).and_return(json)
    r
  end

  let(:expected_msb) do
    'ms15-093'
  end

  before(:each) do
    allow_any_instance_of(PatchFinder::Helper).to receive(:print_status)
    allow_any_instance_of(PatchFinder::Helper).to receive(:send_http_get_request) { |obj, uri|
      case uri
      when /customsearch\/v1\?/
        json_data
      end
    }
  end

  subject do
    described_class.new
  end

  describe '#find_msb_numbers' do
    it 'returns an array of msb numbers' do
      results = subject.find_msb_numbers(expected_msb)
      expect(results).to be_kind_of(Array)
      expect(results).to eq([expected_msb])
    end
  end

  describe '#search' do
    it 'returns a hash (json data)' do
      results = subject.search(starting_index: 1)
      expect(results).to be_kind_of(Hash)
    end
  end

  describe '#parse_results' do
    it 'returns a hash (json data)' do
      results = subject.parse_results(json_data)
      expect(results).to be_kind_of(Hash)
    end
  end

  describe '#get_total_results' do
    it 'returns a fixnum' do
      total = subject.get_total_results(JSON.parse(json_data.body))
      expect(total).to be_kind_of(Fixnum)
    end
  end

  describe '#get_next_index' do
    it 'returns a fixnum' do
      i = subject.get_next_index(JSON.parse(json_data.body))
      expect(i).to be_kind_of(Fixnum)
    end
  end
end
