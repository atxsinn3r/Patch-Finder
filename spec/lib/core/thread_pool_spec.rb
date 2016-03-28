require 'core/thread_pool'

RSpec.describe PatchFinder::ThreadPool do

  subject do
    PatchFinder::ThreadPool.new(max_size)
  end

  let(:max_size) do
    2
  end

  describe '#schedule' do
    it 'adds one thread to queue' do
      subject.schedule { } # no code needed
      expect(subject.instance_variable_get(:@jobs).length).to eq(1)
    end
  end

  describe '#eop?' do
    context 'when there is a thread in the queue' do
      it 'returns false' do
        subject.schedule { } # No code needed
        expect(subject.eop?).to be_falsy
      end
    end

    context 'when the queue is empty' do
      it 'returns true' do
        expect(subject.eop?).to be_truthy
      end
    end
  end

end
