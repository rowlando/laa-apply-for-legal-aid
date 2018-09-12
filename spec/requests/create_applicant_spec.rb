require 'rails_helper'
require 'json_expressions/rspec'
require 'swagger_helper'

RSpec.describe 'Legal aid applications' do
  let(:response_json) { JSON.parse(response.body) }
  let(:application) { LegalAidApplication.create }
  let(:headers) do
    {
      'ACCEPT' => 'application/json',
      'HTTP_ACCEPT' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end

  let(:body) do
    {
      'data': {
        'type': 'legal_aid_applicant',
        'attributes': {
          'name': 'John Doe',
          'date_of_birth': '1991-12-01',
          'application_ref': application.application_ref
        }
      }
    }.to_json
  end

  path '/v1/applicants' do
    post 'Creates an applicant' do
      tags 'Applicants'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :applicant, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              type: { type: :string },
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string },
                  date_of_birth: { type: :string },
                  application_ref: { type: :string }
                }
              }
            }
          }
        }
      }

      response '201', 'applicant created' do
        examples 'application/json' => {
          data: {
            type: 'legal_aid_applicant',
            attributes: {
              name: 'John Doe',
              date_of_birth: '1991-12-01',
              application_ref: '3450ee25-6f06-438b-97cb-3ad095802964'
            }
          }
        }

        let(:applicant) {
          {
            data: {
              type: 'legal_aid_applicant',
              attributes: {
                name: 'John Doe',
                date_of_birth: '1991-12-01',
                application_ref: application.application_ref
              }
            }
          }
        }
        run_test!
        # post '/v1/applicants', params: body, headers: headers
        # expect(response.status).to eql(201)
        # expect(response.content_type).to eql('application/json')
        # expect(response_json['data']['attributes']['name']).to eq('John Doe')
        # expect(response_json['data']['attributes']['date_of_birth']).to eq('1991-12-01')
      end

      it 'creates a new applicant' do
        expect do
          post '/v1/applicants', params: body, headers: headers
        end.to change { Applicant.count }.by(1)
      end

      context 'when the provided date of birth is invalid' do
        it 'returns an error' do
          body_invalid_date = {
            'data': {
              'type': 'legal_aid_applicant',
              'attributes': {
                'name': 'John Doe',
                'date_of_birth': '11-12-01',
                'application_ref': application.application_ref
              }
            }
          }.to_json
          post '/v1/applicants', params: body_invalid_date, headers: headers
          expect(response.status).to eql(400)
          expect(response.content_type).to eql('application/json')
          expect(response_json[0]).to eq('Date of birth is not valid')
        end
      end
    end
  end
end
