require 'rails_helper'

RSpec.describe Providers::DateClientToldIncidentsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:login_provider) { login_as legal_aid_application.provider }

  describe 'GET /providers/applications/:legal_aid_application_id/date_client_told_incident' do
    subject do
      get providers_legal_aid_application_date_client_told_incident_path(legal_aid_application)
    end

    before do
      login_provider
      subject
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      it_behaves_like 'a provider not authenticated'
    end

    context 'with an existing incident' do
      let(:incident) { create :incident }
      let(:legal_aid_application) { create :legal_aid_application, latest_incident: incident }

      it 'renders successfully' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays incident data' do
        expect(response.body).to include(incident.told_on.day.to_s)
        expect(response.body).to include(incident.told_on.month.to_s)
        expect(response.body).to include(incident.told_on.year.to_s)
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/date_client_told_incident' do
    let(:told_on) { 3.days.ago.to_date }
    let(:told_day) { told_on.day }
    let(:params) do
      {
        incident: {
          told_day: told_day,
          told_month: told_on.month,
          told_year: told_on.year
        }
      }
    end
    let(:draft_button) { { draft_button: 'Save as draft' } }
    let(:button_clicked) { {} }
    let(:incident) { legal_aid_application.reload.latest_incident }

    subject do
      patch(
        providers_legal_aid_application_date_client_told_incident_path(legal_aid_application),
        params: params.merge(button_clicked)
      )
    end

    before { login_provider }

    it 'creates a new incident with the values entered' do
      expect { subject }.to change { Incident.count }.by(1)
      expect(incident.told_on).to eq(told_on)
    end

    it 'redirects to the next page' do
      subject
      expect(response).to redirect_to(flow_forward_path)
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when incomplete' do
      let(:told_day) { '' }

      it 'renders show' do
        subject
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when invalid' do
      let(:told_day) { '32' }

      it 'renders show' do
        subject
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when save as draft selected' do
      let(:button_clicked) { draft_button }

      it 'redirects to provider draft endpoint' do
        subject
        expect(response).to redirect_to provider_draft_endpoint
      end
    end
  end
end
