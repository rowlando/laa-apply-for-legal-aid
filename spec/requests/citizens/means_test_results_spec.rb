require 'rails_helper'

RSpec.describe Citizens::MeansTestResultsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }

  before { get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id) }

  describe 'GET /citizens/means_test_result' do
    subject { get citizens_means_test_result_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end
end
