# frozen_string_literal: true

require 'rails_helper'
require_relative '../../app/algorithms/jaro'

# rubocop: disable Metrics/BlockLength
RSpec.describe JaroAlgorithm do
  subject(:distance) { JaroAlgorithm.new(word1, word2).distance }

  describe '#distance' do
    context 'when both words are the same' do
      let(:word1) { 'apple' }
      let(:word2) { 'apple' }

      before { subject }

      it 'returns 1.0' do
        expect(distance).to eq 1.0
      end
    end

    context 'when words are different but has common start' do
      let(:word1) { 'apple' }
      let(:word2) { 'aple' }

      it 'returns the Jaro-Winkler distance -> value is bigger' do
        expect(distance).to be_between(0.9, 1.0).exclusive
      end
    end

    context 'when words are similiar but has no common start' do
      let(:word1) { 'xiapple' }
      let(:word2) { 'apple' }

      it 'returns the Jaro-Winkler distance > value is lesser' do
        expect(distance).to be_between(0.7, 0.8).exclusive
      end
    end

    context 'when words are similiar have different capitalization' do
      let(:word1) { 'aPPlE' }
      let(:word2) { 'AppLe' }

      it 'returns the Jaro-Winkler distance > value is lesser' do
        expect(distance).to eq 1.0
      end
    end

    context 'when one of the words is an empty string' do
      let(:word1) { 'apple' }
      let(:word2) { '' }

      it 'returns 0.0' do
        expect(distance).to eq 0.0
      end
    end

    context 'when both words are empty strings' do
      let(:word1) { '' }
      let(:word2) { '' }

      it 'returns 1.0' do
        expect(distance).to eq 1.0
      end
    end
  end
end
# rubocop: enable Metrics/BlockLength
