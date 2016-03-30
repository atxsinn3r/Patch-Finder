require 'patch_finder/core/helper'
require 'patch_finder/msu'

RSpec.describe PatchFinder::MSU do

  def get_stderr(&block)
    out = $stderr
    $stderr = fake = StringIO.new
    begin
      yield
    ensure
      $stderr = out
    end
    fake.string
  end

  let(:ms15_100_html) do
    %Q|
    <html>
    <div id="mainBody">
      <div>
        <h2>
        <div>
          <span>Affected Software</span>
          <div class="sectionblock">
            <table>
            <tr><td><a href="https://www.microsoft.com/downloads/details.aspx?familyid=1">fake link</a></td></tr>
            </table>
          </div>
        </div>
        </h2>
      </div>
    </div>
    </html>
    |
  end

  let(:ms07_029_html) do
    %Q|
    <html>
    <div id="mainBody">
      <ul>
        <li>
          <a href="http://technet.microsoft.com">Download the update</a>
        </li>
      </ul>
    </div>
    </html>
    |
  end

  let(:ms03_039_html) do
    %Q|
    <html>
    <div id="mainBody">
      <div>
        <div class="sectionblock">
          <p>
            <strong>Download locations</strong>
          </p>
          <ul>
            <li>
              <a href="http://technet.microsoft.com">Download</a>
            </li>
          </ul>
        </div>
      </div>
    </div>
    </html>
    |
  end

  let(:ms07_030_html) do
    %Q|
    <html>
    <div id="mainBody">
      <p>
        <strong>Affected Software</strong>
      </p>
      <table>
      <tr><td><a href="http://technet.microsoft.com">Download</a></td></tr>
    </div>
    </html>
    |
  end

  let(:expected_download_link) do
    'https://download.microsoft.com/download/9/0/6/906BC7A4-7DF7-4C24-9F9D-3E801AA36ED3/Windows6.0-KB3087918-x86.msu'
  end

  before(:each) do
    allow_any_instance_of(PatchFinder::Helper).to receive(:print_error)
    allow_any_instance_of(PatchFinder::Helper).to receive(:send_http_get_request) { |obj, uri|
      case uri
      when /https:\/\/www\.microsoft\.com\/en\-us\/download\//
        html = %Q|<html>
        <a href="#{expected_download_link}">Click here</a>
        </html>
        |
      when /https:\/\/technet\.microsoft\.com\/en\-us\/library\/security\//
        html = %Q|Vulnerability in Virtual Address Descriptor Manipulation Could Allow Elevation of Privilege|
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

  describe '#collect_msbs' do
    before do
      allow(subject).to receive(:technet_search)
      allow(subject).to receive(:google_search)
    end

    context 'when technet is used' do
      it 'shows it is searching via technet' do
        opts = { search_engine: :technet, keyword: 'ms15-100' }
        output = get_stderr { subject.send(:collect_msbs, opts) }
        expect(output).to include('via Technet')
      end
    end

    context 'when google is used' do
      it 'shows it is searching via google' do
        opts = { search_engine: :google, keyword: 'ms15-100' }
        output = get_stderr { subject.send(:collect_msbs, opts) }
        expect(output).to include('via Google')
      end
    end
  end

  describe '#collect_links_from_msb' do
    it 'returns an array' do
      expect(subject.send(:collect_links_from_msb, 'ms15-100')).to be_kind_of(Array)
    end
  end

  describe '#google_search' do
    skip 'repeated test case in the google_spec'
  end

  describe '#technet_search' do
    skip 'repeated test case in technet_spec'
  end

  describe '#download_advisory' do
    it 'returns an HTTP response' do
      res = subject.send(:download_advisory, 'ms15-100')
      expect(res.body).to include('Vulnerability')
    end
  end

  describe '#get_details_aspx' do
    let(:details_aspx) do
      r = double('Net::HTTPOK')
      allow(r).to receive(:http_version).and_return('1.1')
      allow(r).to receive(:code).and_return(200)
      allow(r).to receive(:message).and_return('OK')
      allow(r).to receive(:body).and_return(ms15_100_html)
      r
    end

    let(:results) do
      @results ||= subject.send(:get_details_aspx, details_aspx)
    end

    it 'returns an array' do
      expect(results).to be_kind_of(Array)
    end

    it 'returns strings in the array' do
      results.each do |item|
        expect(item).to be_kind_of(String)
      end
    end

    it 'returns an URI in the item' do
      expected_uri = 'https://www.microsoft.com/downloads/details.aspx?familyid=1'
      expect(results.first).to eq(expected_uri)
    end
  end

  describe '#get_download_links' do
    let(:confirm_aspx) do
      %Q|
      <html>
      <a href="https://www.microsoft.com/en-us/download/confirmation.aspx?id=1">Download</a>
      </html>
      |
    end

    it 'returns an array of links' do
      expect(subject.send(:get_download_links, confirm_aspx).first).to eq(expected_download_link)
    end
  end

  describe '#get_appropriate_pattern' do
    it 'returns a pattern for ms15-100' do
      expected_pattern = '//div[@id="mainBody"]//div//div[@class="sectionblock"]//table//a'
      p = subject.send(:get_appropriate_pattern, ::Nokogiri::HTML(ms15_100_html))
      expect(p).to eq(expected_pattern)
    end

    it 'returns a pattern for ms07-029' do
      expected_pattern = '//div[@id="mainBody"]//ul//li//a[contains(text(), "Download the update")]'
      p = subject.send(:get_appropriate_pattern, ::Nokogiri::HTML(ms07_029_html))
      expect(p).to eq(expected_pattern)
    end

    it 'returns a pattern for ms03-039' do
      expected_pattern = '//div[@id="mainBody"]//div//div[@class="sectionblock"]//ul//li//a'
      p = subject.send(:get_appropriate_pattern, ::Nokogiri::HTML(ms03_039_html))
      expect(p).to eq(expected_pattern)
    end

    it 'returns a pattern for ms07-030' do
      expected_pattern = '//div[@id="mainBody"]//table//a'
      p = subject.send(:get_appropriate_pattern, ::Nokogiri::HTML(ms07_030_html))
      expect(p).to eq(expected_pattern)
    end
  end

  describe '#has_advisory?' do
    let(:response_body) do
      'We are sorry. The page you requested cannot be found'
    end

    let(:res) do
      r = double('Net::HTTPOK')
      allow(r).to receive(:http_version).and_return('1.1')
      allow(r).to receive(:code).and_return(200)
      allow(r).to receive(:message).and_return('OK')
      allow(r).to receive(:body).and_return(response_body)
      r
    end

    context 'when an advisory is not found' do
      it 'returns false' do
        expect(subject.send(:has_advisory?, res)).to be_falsey
      end
    end
  end

  describe '#is_valid_msb?' do
    let(:good_msb) do
      'MS15-100'
    end

    let(:bad_msb) do
      'MS15-01'
    end

    context 'when the MSB format is correct' do
      it 'returns true' do
        expect(subject.send(:is_valid_msb?, good_msb)).to be_truthy
      end
    end

    context 'when the MSB format is incorrect' do
      it 'returns false' do
        expect(subject.send(:is_valid_msb?, bad_msb)).to be_falsey
      end
    end
  end
end
