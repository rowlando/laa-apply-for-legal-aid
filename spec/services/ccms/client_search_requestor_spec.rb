require 'rails_helper'

module CCMS
  RSpec.describe ClientSearchRequestor do
    describe 'XML request' do
      it 'generates the expected XML' do
        with_modified_env(modified_environment_vars) do
          requestor = described_class.new
          allow(requestor).to receive(:transaction_request_id).and_return('20190101121530123456')
          expect(requestor.formatted_xml).to eq expected_xml.chomp
        end
      end
    end

    describe '#transaction_request_id' do
      it 'returns the id based on current time' do
        Timecop.freeze(2019, 1, 2, 3, 4, 5.123456) do
          requestor = described_class.new
          expect(requestor.transaction_request_id).to eq '20190102030405123456'
        end
      end
    end

    def modified_environment_vars
      {
        'SOAP_CLIENT_USERNAME' => 'my_soap_client_username',
        'SOAP_CLIENT_PASSWORD' => 'xxxxx',
        'USER_LOGIN' => 'my_login',
        'USER_ROLE' => 'my_role'
      }
    end

    def expected_xml
      File.read("#{File.dirname(__FILE__)}/data/expected_client_search_request.xml")
    end
  end
end
