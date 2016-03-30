require 'patch_finder/core/helper'

RSpec.describe PatchFinder::Helper do

  subject do
    obj = Object.new
    obj.extend(described_class)
  end

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

  def get_stdout(&block)
    out = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = out
    end
    fake.string
  end

  describe '#print_verbose' do
    it 'prints a message with prefix [*]' do
      subject.verbose = true
      output = get_stderr { subject.print_verbose('message') }
      expect(output).to include('[*]')
    end
  end

  describe '#print_status' do
    it 'prints a message with prefix [*]' do
      output = get_stderr { subject.print_status('message') }
      expect(output).to include('[*]')
    end
  end

  describe '#print_error' do
    it 'prints a message with prefix [ERROR]' do
      output = get_stderr { subject.print_error('message') }
      expect(output).to include('[ERROR]')
    end
  end

  describe '#print_line' do
    it 'prints a message without a prefix' do
      msg = 'message'
      output = get_stdout { subject.print_line(msg) }
      expect(output).to include(msg)
    end
  end

  describe '#send_http_get_request' do
    context 'when it sends a request to rapid7.com' do
      it 'returns a Net::HTTPResponse object' do
        res = subject.send_http_get_request('http://rapid7.com')
        expect(res).to be_kind_of(Net::HTTPResponse)
      end
    end

    context 'when it sends a request to https://rapid7.com' do
      it 'returns a Net::HTTPResponse object' do
        res = subject.send_http_get_request('https://rapid7.com')
        expect(res).to be_kind_of(Net::HTTPResponse)
      end
    end
  end

  describe '#read_file' do
    let(:content) do
      'CONTENT'
    end

    before do
      f = double('file')
      allow(f).to receive(:read).and_return(content)
      allow(File).to receive(:open).with(an_instance_of(String), an_instance_of(String)).and_yield(f)
      allow(File).to receive(:exist?).with(an_instance_of(String)).and_return(true)
    end

    it 'returns the content of a file' do
      data = subject.read_file('file_path')
      expect(data).to eq(content)
    end
  end

  describe '#download_file' do
    before do
      res = double('Net::HTTPResponse')
      allow(res).to receive(:body).and_return('OK')
      allow(subject).to receive(:send_http_get_request).and_return(res)
    end

    it 'prints Download Completed' do
      output = get_stderr { subject.download_file('http://example.com/test.msu', '/tmp') }
      expect(output).to include('Download completed')
    end
  end

  # Private methods

  describe '#save_file' do
    let(:expected_content) do
      'expected content'
    end

    let(:file_path) do
      '/file_path'
    end

    let(:saved_content) do
      @saved_content ||= ''
    end

    before do
      f = double('f')
      allow(f).to receive(:write) { |data| @saved_content = data}
      allow(File).to receive(:open).with(an_instance_of(String), an_instance_of(String)).and_yield(f)
    end

    it 'should write \'content\'' do
      subject.send(:save_file, expected_content, file_path)
      expect(@saved_content).to eq(expected_content)
    end
  end

  describe '#normalize_uri' do
    let(:expected_value) do
      '/'
    end

    it 'removes double slashes' do
      expect(subject.send(:normalize_uri, '//')).to eq('/')
    end
  end

end
