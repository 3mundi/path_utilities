require 'spec_helper'
module PathUtilities
  class ProfileTranslator < PathUtilities::CSV::Translator

    def date_format
      '%Y-%m-%d'
    end

    def key_mapping
      {
        name: :first_name,
        lastname: :last_name,
        birthday: :birth_date,
        prefix: :prefix,
        gender: :gender,
        gds_code: {key: :profile_name,
                   proc: -> (value) do
                           value.gsub(/\[|\]/,'')
                         end
        },
        home_phone: :personal_phone,
        mobile_phone: :business_mobile_phone,
        work_phone: :business_phone,
        subsidiary: :company_id,
        home_street: [:personal_address_line_1,
                      :personal_address_line_2,
                      :personal_address_line_3,
                      :personal_address_line_4,
                      :personal_address_line_5,
                      :personal_address_line_6],
        home_city: :personal_city,
        home_province: :personal_state_code,
        home_zip: :personal_postal_code,
        home_country: :personal_country_code,
        traveller_category_id: :traveler_category_id,
        user_status: :status,
        login_id: :login,
        employee_id: :employee_id,
        email_1: :business_email
      }
    end
  end


  describe CSV::Translator do
    hash =
        {
          record_type_identifier: "EMPLOYEE_COMPLETE",
          employee_id: "CODE_1529639_cec/flo",
          employee_number: "",
          profile_name: '[RJTRJN]',
          login: "cec/flo",
          password: "",
          prefix: "MR",
          first_name: "name",
          last_name: "lastname",
          middle_name: "",
          business_phone: '+34 699 88 88 88',
          business_fax: "",
          business_mobile_phone: "+34 677 77 77 77",
          business_email: "blabla@bla.com",
          company_address_id: "",
          company_id: "CEC",
          cost_center_id: "",
          traveler_category_id: "traveller_category_id_value",
          corporate_card_number: "",
          corporate_card_type: "",
          corporate_card_expiration_date: "",
          personal_address_line_1: "line_1",
          personal_address_line_2: "line_2",
          personal_address_line_3: "line_3",
          personal_address_line_4: "line_4",
          personal_address_line_5: "line_5",
          personal_address_line_6: "line_6",
          personal_city: "Barcelona",
          personal_postal_code: "08001",
          personal_country_code: "ES",
          personal_state_code: "BCN",
          personal_phone: "+34 678 99 99 99",
          personal_fax: "",
          personal_mobile_phone: "",
          personal_email: "",
          language: "FR",
          date_display_order: "DD/MM/YYYY",
          currency: "EUR",
          home_city_airport: "",
          air_preferred_meal: "",
          air_smoking: "N",
          air_seat: "",
          birth_date: "1994-11-14",
          is_booking_allowed: "Y",
          status: "Y"
        }
    describe '#output' do
      before :all do
        object = ProfileTranslator.new([hash])
        object.execute
        @output = object.output
      end
      describe 'first' do
        let(:first) { @output.first }
        # it { byebug }
        {
          name: 'name',
          lastname: 'lastname',
          home_phone:'+34 678 99 99 99',
          work_phone: '+34 699 88 88 88',
          mobile_phone: '+34 677 77 77 77',
          prefix: 'MR',
          subsidiary: 'CEC',
          home_street: 'line_1, line_2, line_3, line_4, line_5, line_6',
          home_city: 'Barcelona',
          home_province: 'BCN',
          home_zip: '08001',
          home_country: 'ES',
          gds_code: 'RJTRJN',
          birthday: '1994-11-14',
          user_status: 'Y',
          employee_id: "CODE_1529639_cec/flo",
          login_id: "cec/flo",
          email_1: 'blabla@bla.com',
          traveller_category_id: 'traveller_category_id_value'
        }.each do |key, value|
          it "#{key} should be: #{value}" do
            first[key].should eq value
          end
        end
      end

    end
    context 'when personal address is empty' do
      before :all do
        empty = {
          personal_address_line_1: '',
          personal_address_line_2: '',
          personal_address_line_3: '',
          personal_address_line_4: '',
          personal_address_line_5: '',
          personal_address_line_6: ''
        }
        corner_hash = hash.merge(empty)
        object = ProfileTranslator.new([corner_hash])
        object.execute
        @output = object.output
      end
      it 'home_address should be empty' do
        expect(
          @output.first[:home_street]
        ).to eq ''
      end
    end
    describe 'translator inheritance' do
      let(:object) { ProfileTranslator.new([hash]) }
      [
        :date_format,
        :execute,
        :key_mapping,
      ].each do |message|
        it "should respond to #{message}" do
          object.should respond_to(message)
        end
      end
    end
  end
end
