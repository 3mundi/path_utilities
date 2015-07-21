require 'spec_helper'
module PathUtilities
  module CSV
    describe FileReader do
      let(:file_path) { File.expand_path('../../fixtures/example.csv', __FILE__) }
      subject { described_class.new(file_path) }
      let(:output) { subject.tap{|o| o.execute }.output }
      it 'should return array with 99 elements' do
        expect(output.count).to eq 6
      end
      describe 'each element' do
        it 'should return array with 15 elements' do
          expect(output.first.count).to eq 35
        end
      end
    end
  end
end
