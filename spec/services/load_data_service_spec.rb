# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoadDataService do
  describe '#call' do
    subject(:call) { LoadDataService.new.call }

    context 'when the file exists' do
      it 'returns parsed data from the file' do
        expect(call).to be_an_instance_of(Array)
        expect(call.first.keys).to eq ['Name', 'Type', 'Designed by']
      end
    end

    context 'when the file does not exist' do
      before { allow(File).to receive(:exist?).and_return(false) }

      it 'raises exception' do
        expect { call }.to raise_error(FileNotFoundException)
      end
    end
  end
end
