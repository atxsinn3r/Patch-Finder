require 'patch_finder/core/thread_pool'

RSpec.describe PatchFinder::ThreadPool do

  let(:max_size) do
    2
  end

  subject do
    PatchFinder::ThreadPool.new(max_size)
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
