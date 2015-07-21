require 'spec_helper'
module PathUtilities
  class CSV::ProfileMapper < CSV::Mapper

    private

    def keys
      [
        :record_type_identifier,
        :employee_id,
        :employee_number,
      ]
    end
  end

  describe CSV::Mapper do
    describe 'single line' do
      let(:line) { 'EMPLOYEE_COMPLETE;RHG9529164;9529164;[RSB7F5];' }
      let(:splited) { line.split(';') }
      let(:input) { [splited] }
      subject { CSV::ProfileMapper.new(input).tap{|o| o.execute }.output.first }
      out = {:record_type_identifier=>"EMPLOYEE_COMPLETE", :employee_id=>"RHG9529164", :employee_number=>"9529164"}
      out.each do |k, v|
        it "#{k} is '#{v}'" do
          expect(subject[k]).to eq v
        end
      end
    end
  end
end
