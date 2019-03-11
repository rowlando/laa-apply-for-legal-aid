module CCMS
  class AddCaseRequestor < BaseRequestor
    NAMESPACES = {
    'xmlns:ns6' => "http://legalservices.gov.uk/Enterprise/Common/1.0/Header" ,
    'xmlns:ns5' => 'http://legalservices.gov.uk/CCMS/Finance/Payables/1.0/BillingBIO',
    'xmlns:ns7' => 'uri',
    'xmlns:ns0' => 'http://legalservices.gov.uk/Enterprise/Common/1.0/Common',
    'xmlns:ns2' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIO',
    'xmlns:ns1' => 'http://legalservices.gov.uk/CCMS/CaseManagement/Case/1.0/CaseBIM',
    'xmlns:ns4' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
    'xmlns:ns3 '=> 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'
    }.freeze

    WSDL_LOCATION = "#{File.dirname(__FILE__)}/wsdls/CaseServicesWsdl.xml".freeze

    def initialize(legal_aid_application)
      super(WSDL_LOCATION, NAMESPACES)
      @legal_aid_application = legal_aid_application
      @transaction_time_stamp = Time.now.strftime("%Y-%m_%dT%H:%M:%3S")
      @ccms_attribute_keys = YAML.load_file(File.join(Rails.root, 'config', 'ccms', 'ccms_keys.yml'))
    end


    # temporarily ignore this until connectivity with ccms is working
    # :nocov:
    def call
      # @soap_client.call(:create_case_application, soap_header: header_message, message: body_message)
      @soap_client.call(:create_case_application, message: body_message)
    end
    # :nocov:

    private

    def request
      @request ||= @soap_client.build_request(:create_case_application,
                                              soap_header: soap_header,
                                              message: body_message)
    end

    def body_message
      {
        'ns6:HeaderRQ' => header_request_message,
        'ns1:Case' => {
          'ns2:CaseReferenceNumber' => @legal_aid_application.ccms_reference_number,
          'ns2:CaseDetails' => {
            'ns2:ApplicationDetails' => application_detail_message,
            'ns2:RecordHistory' => record_history_message,
            'ns2:CaseDocs' => placeholder_message
          }
        }
      }
    end

    def soap_header
      {}
    end

    def header_request_message
      {
        'ns6:TransactionRequestID' => transaction_request_id,
        'ns6:Language' => 'ENG',
        'ns6:UserLoginID' => ENV['USER_LOGIN'],
        'ns6:UserRole' => ENV['USER_ROLE'],
        'ns6:Timestamp' => @transaction_time_stamp
      }
    end

    def application_detail_message
      {
        'ns2:Client' => client_message,
        'ns2:PreferredAddress' => 'CLIENT',
        'ns2:ProviderDetails' => provider_details_message,
        'ns2:CategoryOfLaw' => category_of_law_message,
        'ns2:OtherParties' => other_parties_message,
        'ns2:Proceedings!' => proceedings_message_xml,
        'ns2:MeansAssesments' => means_assessment_message,
        'ns2:MeritsAssesments' => placeholder_message,
        'ns2:DevolvedPowersDate' => placeholder_message,
        'ns2:ApplicationAmendmentType' => placeholder_message,
        'ns2:LARDetails' => placeholder_message
      }
    end

    def client_message
      applicant = @legal_aid_application.applicant
      {
        'ns2:ClientReferenceNumber' => applicant.ccms_reference_number,
        'ns2:FirstName' => applicant.first_name,
        'ns2:Surname' => applicant.last_name
      }
    end

    def provider_details_message
      provider = @legal_aid_application.provider
      {
        'ns2:ProviderCaseReferenceNumber' => @legal_aid_application.provider_case_reference_number,
        'ns2:ProviderFirmID' => provider.firm_id,
        'ns2:ProviderOfficeID' => provider.office_id,
        'ns2:ContactUserID' => {
          'ns0:UserLoginID' => provider.contact_user_id,
        },
        'ns2:SupervisorContactID' => provider.supervisor_user_id,
        'ns2:FeeEarnerContactID' => provider.fee_earner_contact_id
      }
    end

    def category_of_law_message
      proceeding = @legal_aid_application.proceeding_types.first
      {
        'ns2:CategoryOfLawCode' => proceeding.ccms_category_law_code,
        'ns2:CategoryOfLawDescription' => proceeding.ccms_category_law,
        'ns2:RequestedAmount' => to_decimal(@legal_aid_application.requested_amount),
      }
    end

    def other_parties_message
      nil
    end

    # there are more than one <Proceeding> nodes withing the <Proceedings> element, so
    # we have to do something like this:
    # >  Gyoku.xml({languages: [{language: 'ruby'},{language: 'java'}]}, { unwrap: true})
    # => "<languages><language>ruby</language><language>java</language></languages>"

    def proceedings_message_xml
      # we have to include raw xml at this point to make sure that the
      # array here is "unwrapped", i.e., the enclosing xml element name is
      # not repeated
      Gyoku.xml({ 'ns2:Proceedings' => multiple_proceeding_hash })
    end

    def multiple_proceeding_hash
      @legal_aid_application.proceeding_types.map { |p| proceeding_message(p) }
    end

    def proceeding_message(proceeding)
      {
        'ns2:Proceeding' => {
          'ns2:ProceedingCaseID' => proceeding.proceeding_case_id,
          'ns2:Status' => proceeding.status,
          'ns2:LeadProceedingIndicator' => proceeding.lead_proceeding_indicator,
          'ns2:ProceedingDetails' => {
            'ns2:ProceedingType' => proceeding.ccms_code,
            'ns2:ProceedingDescription' => proceeding.description,
            'ns2:MatterType' => proceeding.ccms_matter_code,
            'ns2:LevelOfService' => 3,
            'ns2:Stage' => 8,
            'ns2:ClientInvolvementType' => 'A',
            'ns2:ScopeLimitations' => proceeding.scope_limitations.map{ |sl| scope_limitation_message(sl) },
          }
        }
      }
    end

    def scope_limitation_message(scope_limitation)
      {
        'ns2:ScopeLimitation' => {
          'ns2:ScopeLimitation' => scope_limitation.limitation,
          'ns2:ScopeLimitationWording' => scope_limitation.wording,
          'ns2:DelegatedFunctionsApply' => scope_limitation.delegated_functions_apply
        }
      }
    end

    def record_history_message
      nil
    end

    def means_assessment_message
      {
        'ns0:AssessmentResults' => {
          'ns0:Results' => assessment_results_message,
          'ns0:AssessmentDetails' => assessment_details_message
        }
      }
    end

    def assessment_results_message
      {
        'ns0:Goal' => {
          'ns0:Attribute' => 'CLIENT_PROV_LA',
          'ns0:AttributeValue' => true
        }
      }
    end

    def assessment_details_message
      {
        'ns0:AssessmentScreens' => {
          'ns0:ScreenName' => 'SUMMARY',
          'ns0:Entity' => means_assessment_entities
        }
      }
    end

    def means_assessment_entities
      [ valuable_possession_entity, bank_account_entity ]
    end

    def valuable_possession_entity
      {
        'ns0:SequenceNumber' => 1,
        'ns0:EntityName' => 'VALUABLE_POSSESSION',
        'ns0:Instances' => {
          'ns0:InstanceLabel' => 'the valuable possession1',
          'ns0:Attribute' => attribute_hash_array(:valuable_possessions)
        }
      }
    end

    def bank_account_entity
      {
        'ns0:SequenceNumber' => 2,
        'ns0:EntityName' => 'BANKACC',
        'ns0:Instances' => {
          'ns0:InstanceLabel' => 'the bank acccount1',
          'ns0:Attribute' => attribute_hash_array(:bank_acct)
        }
      }
    end

    def attribute_hash_array(section)
      keys = @ccms_attribute_keys[section.to_s]
      result_array = []
      keys.each do |ccms_attribute_key, ccms_attribute_elements|
        result_hash = {
          'ns0:Attribute' => ccms_attribute_key,
          'ns0:ResponseType' => ccms_attribute_elements[:response_type],
          'ns0:ResponseValue' => ccms_attribute_elements[:value],
          'ns0:UserDefinedInd' => ccms_attribute_elements[:user_defined],
        }
        result_array << result_hash
      end
      result_array
    end



    def placeholder_message
      'PLACEHOLDER MESSAGE'
    end

    def to_decimal(number, number_of_places = 2)
      sprintf("%.#{number_of_places}f", number.round(number_of_places))
    end
  end
end
