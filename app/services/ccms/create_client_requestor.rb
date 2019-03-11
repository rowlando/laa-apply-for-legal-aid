module CCMS
  class CreateClientRequestor < BaseRequestor
    NAMESPACES = {
      'xmlns:ns1' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
      'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIM',
      'xmlns:ns3' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Header',
      'xmlns:ns4' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
      'xmlns:ns5' => 'http://legalservices.gov.uk/CCMS/ClientManagement/Client/1.0/ClientBIO'
    }.freeze

    WSDL_LOCATION = "#{File.dirname(__FILE__)}/wsdls/ClientProxyServiceWsdl.xml".freeze

    def initialize
      super(WSDL_LOCATION, NAMESPACES)
    end

    # temporarily ignore this until connectivity with ccms is working
    # :nocov:
    def call
      @soap_client.call(:create_client, soap_header: header_message, message: body_message)
    end
    # :nocov:

    private

    def request
      @request ||= @soap_client.build_request(:create_client, soap_header: header_message, message: body_message)
    end

    def body_message
      {
        'ns3:HeaderRQ' => header_request,
        'ns2:Client' => client
      }
    end

    def header_request
      {
        'ns3:TransactionRequestID' => transaction_request_id,
        'ns3:Language' => 'ENG',
        'ns3:UserLoginID' => ENV['USER_LOGIN'],
        'ns3:UserRole' => ENV['USER_ROLE']
      }
    end

    def client
      {
        'ns4:Name' => name,
        'ns4:PersonalInformation' => personal_information,
        'ns4:Contacts' => contacts,
        'ns4:DisabilityMonitoring' => {
          'ns4:DisabilityType' => 'OTHER'
        },
        'ns4:NoFixedAbode' => false,
        'ns4:Address' => address,
        'ns4:EthnicMonitoring' => 0
      }
    end

    def name
      {
        'ns4:Surname' => 'Hurlock',
        'ns4:FirstName' => 'lenovo'
      }
    end

    def personal_information
      {
        'ns4:DateOfBirth' => '1969-01-01',
        'ns4:Gender' => 'FEMALE',
        'ns4:MaritalStatus' => 'U',
        'ns4:VulnerableClient' => 'false',
        'ns4:HighProfileClient' => 'false Hurlock',
        'ns4:VexatiousLitigant' => 'false',
        'ns4:CountryOfOrigin' => 'GBR',
        'ns4:MentalCapacityInd' => 'false'
      }
    end

    def contacts
      {
        'ns4:Password' => 'Testing'
      }
    end

    def address
      {
        'ns4:AddressLine1' => '102 Petty France',
        'ns4:City' => 'London',
        'ns4:Country' => 'GBR',
        'ns4:PostalCode' => 'SW1H 9AJ'
      }
    end
  end
end
