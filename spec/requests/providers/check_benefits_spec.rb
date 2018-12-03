require 'rails_helper'

RSpec.describe 'check benefits requests', type: :request do
  let(:last_name) { 'WALKER' }
  let(:date_of_birth) { '1980/01/10'.to_date }
  let(:national_insurance_number) { 'JA293483A' }
  let(:applicant) { create :applicant, last_name: last_name, date_of_birth: date_of_birth, national_insurance_number: national_insurance_number }
  let(:application) { create :application, applicant: applicant }
  let(:address_lookup_used) { true }

  describe 'GET /providers/applications/:application_id/check_benefits', :vcr do
    let(:get_request) { get "/providers/applications/#{application.id}/check_benefits" }

    before do
      create :address, applicant: applicant, lookup_used: address_lookup_used
    end

    it 'returns http success' do
      get_request
      expect(response).to have_http_status(:ok)
    end

    context "the applicant's address used the lookup service" do
      let(:address_lookup_used) { true }

      it 'has a back link to the address lookup page' do
        get_request
        expect(unescaped_response_body).to include(providers_legal_aid_application_address_selection_path)
      end
    end

    context "the applicant's address used manual entry" do
      let(:address_lookup_used) { false }

      it 'has a back link to the address lookup page' do
        get_request
        expect(unescaped_response_body).to include(providers_legal_aid_application_address_path)
      end
    end

    context 'when the check_benefit_result does not exist' do
      it 'generates a new check_benefit_result' do
        expect { get_request }.to change { BenefitCheckResult.count }.by(1)
      end
    end

    context 'when the check_benefit_result already exists' do
      let!(:benefit_check_result) { create :benefit_check_result, legal_aid_application: application }

      it 'does not generate a new one' do
        expect_any_instance_of(BenefitCheckService).not_to receive(:call).and_call_original
        expect { get_request }.to_not change { BenefitCheckResult.count }
      end

      context 'and the applicant has since been modified' do
        before { applicant.update(first_name: Faker::Name.first_name) }

        it 'updates check_benefit_result' do
          expect_any_instance_of(BenefitCheckService).to receive(:call).and_call_original
          get_request
        end
      end
    end
  end
end
