require 'core/helper'
require 'engine/msu/technet'

RSpec.describe PatchFinder::Engine::MSU::Technet do

  let(:bulletins_page) do
    %Q|
    <div class="sb-search">
    <div class="SearchBox">
    <input type="text" id="txtSearch" title="Search Security Bulletins" value="Search Security Bulletins" />
    <input type="button" id="btnSearch" />
    </div>
    <select id="productDropdown">
    <option value="-1">All</option>
    <option value="10175">Active Directory</option>
    <option value="10401">Windows Internet Explorer 10</option>
    <option value="10486">Windows Internet Explorer 11</option>
    <option value="1282">Windows Internet Explorer 7</option>
    <option value="1233">Windows Internet Explorer 8</option>
    <option value="10054">Windows Internet Explorer 9</option>
    </select>
    </div>
    |
  end

  let(:ms15_100_bulletin) do
    %Q|{
            "l":1,
            "b":[
              {
                "d":"9/8/2015",
                "Id":"MS15-100",
                "KB":"3087918",
                "Title":"Vulnerability in Windows Media Center Could Allow Remote Code Execution",
                "Rating":"Important"
              }
            ]
          }
      |
  end

  before(:each) do
    allow_any_instance_of(PatchFinder::Helper).to receive(:print_status)
    allow_any_instance_of(PatchFinder::Helper).to receive(:send_http_get_request) { |obj, uri|
      case uri
      when /en-us\/security\/bulletin\/dn602597\.aspx/
        html = bulletins_page
      when /\/security\/bulletin\/services\/GetBulletins/
        html = ms15_100_bulletin
      else
        html = ''
      end

      r = double('Net::HTTPOK')
      allow(r).to receive(:http_version).and_return('1.1')
      allow(r).to receive(:code).and_return(200)
      allow(r).to receive(:message).and_return('OK')
      allow(r).to receive(:body).and_return(html)
      r
    }
  end

  subject do
    described_class.new
  end

  let(:ie10) do
    'Windows Internet Explorer 10'
  end

  let(:ie10_id) do
    10401
  end

  describe '#find_msb_numbers' do
    let(:msb_numbers) do
      subject.find_msb_numbers(ie10)
    end

    it 'returns an array' do
      expect(msb_numbers).to be_kind_of(Array)
    end

    it 'returns MSB numbers' do
      expect(msb_numbers.first).to eq('ms15-100')
    end
  end

  describe '#search' do
    it 'returns search results in JSON format' do
      results = subject.search(ie10)
      expect(results).to be_kind_of(Hash)
      expect(results['b'].first['Id']).to eq('MS15-100')
    end
  end

  describe '#search_by_product_ids' do
    it 'returns an array of found MSB numbers' do
      results = subject.search_by_product_ids([ie10_id])
      expect(results).to be_kind_of(Array)
      expect(results.first).to eq('ms15-100')
    end
  end

  describe '#search_by_keyword' do
    it 'returns an array of found MSB numbers' do
      results = subject.search_by_keyword('ms15-100')
      expect(results).to be_kind_of(Array)
      expect(results.first).to eq('ms15-100')
    end
  end

  describe '#get_product_dropdown_list' do
    it 'returns an array of products' do
      results = subject.get_product_dropdown_list
      expect(results).to be_kind_of(Array)
      expect(results.first).to be_kind_of(Hash)
      expected_hash = {:option_value=>"10175", :option_text=>"Active Directory"}
      expect(results.first).to eq(expected_hash)
    end
  end

end
