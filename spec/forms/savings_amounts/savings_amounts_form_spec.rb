require 'rails_helper'

RSpec.describe SavingsAmounts::SavingsAmountsForm, type: :form do
  let(:savings_amount) { create :savings_amount }
  let(:attributes) { described_class::ATTRIBUTES }
  let(:check_box_attributes) { described_class::CHECK_BOXES_ATTRIBUTES }
  let(:check_box_params) { {} }
  let(:amount_params) { {} }
  let(:params) { amount_params.merge(check_box_params) }
  let(:form_params) { params.merge(model: savings_amount) }

  subject { described_class.new(form_params) }

  describe '#save' do
    context 'check boxes are checked' do
      let(:check_box_params) { check_box_attributes.each_with_object({}) { |attr, hsh| hsh[attr] = 'true' } }

      context 'amounts are valid' do
        let(:amount_params) { attributes.each_with_object({}) { |attr, hsh| hsh[attr] = Faker::Number.decimal.to_s } }

        it 'updates all amounts' do
          subject.save
          savings_amount.reload

          attributes.each do |attr|
            val = savings_amount.send(attr)
            expected_val = params[attr]
            expect(val.to_s).to eq(expected_val), "Attr #{attr}: expected #{expected_val}, got #{val}"
          end
        end

        it 'returns true' do
          expect(subject.save).to eq(true)
        end

        it 'has no errors' do
          expect(subject.errors).to be_empty
        end
      end

      shared_examples_for 'it has an error' do
        let(:attribute_map) do
          {
            isa: /total in.*accounts/i,
            cash: /total.*cash savings/i,
            other_person_account: /other people’s accounts/,
            national_savings: /certificates and bonds/,
            plc_shares: /shares/,
            peps_unit_trusts_capital_bonds_gov_stocks: /total.*of other investments/i,
            life_assurance_endowment_policy: /total.*of life assurance policies/i
          }
        end
        it 'returns false' do
          expect(subject.save).to eq(false)
        end

        it 'generates errors' do
          subject.save
          attributes.each do |attr|
            error_message = subject.errors[attr].first
            expect(error_message).to match(expected_error)
            expect(error_message).to match(attribute_map[attr.to_sym])
          end
        end

        it 'does not update the model' do
          expect { subject.save }.not_to change { savings_amount.reload.updated_at }
        end
      end

      context 'amounts are empty' do
        let(:amount_params) { attributes.each_with_object({}) { |attr, hsh| hsh[attr] = '' } }
        let(:expected_error) { /enter the( estimated)? total/i }

        it_behaves_like 'it has an error'
      end

      context 'amounts are not numbers' do
        let(:amount_params) { attributes.each_with_object({}) { |attr, hsh| hsh[attr] = Faker::Lorem.word } }
        let(:expected_error) { /must be an amount of money, like 60,000/ }

        it_behaves_like 'it has an error'
      end

      context 'amounts are less than 0' do
        let(:amount_params) { attributes.each_with_object({}) { |attr, hsh| hsh[attr] = Faker::Number.negative.to_s } }
        let(:expected_error) { /must be 0 or more/ }

        it_behaves_like 'it has an error'
      end

      context 'amounts have a £ symbol' do
        let(:amount_params) { attributes.each_with_object({}) { |attr, hsh| hsh[attr] = "£#{Faker::Number.decimal}" } }

        it 'strips the values of £ symbols' do
          subject.save
          savings_amount.reload

          attributes.each do |attr|
            val = savings_amount.send(attr).to_s
            expected_val = params[attr]

            expect("£#{val}").to eq(expected_val), "Attr #{attr}: expected #{expected_val}, got £#{val}"
          end
        end
      end
    end

    context 'check boxes are unchecked' do
      let(:check_box_params) { check_box_attributes.each_with_object({}) { |attr, hsh| hsh[attr] = '' } }

      shared_examples_for 'it empties amounts' do
        it 'empties amounts' do
          subject.save
          savings_amount.reload

          attributes.each do |attr|
            val = savings_amount.send(attr)
            expect(val).to eq(nil), "Attr #{attr}: expected nil, got #{val}"
          end
        end

        it 'returns true' do
          expect(subject.save).to eq(true)
        end

        it 'has no errors' do
          expect(subject.errors).to be_empty
        end
      end

      context 'amounts are valid' do
        let(:amount_params) { attributes.each_with_object({}) { |attr, hsh| hsh[attr] = Faker::Number.decimal.to_s } }
        it_behaves_like 'it empties amounts'
      end

      context 'amounts are not valid' do
        let(:amount_params) { attributes.each_with_object({}) { |attr, hsh| hsh[attr] = Faker::Lorem.word } }
        it_behaves_like 'it empties amounts'
      end
    end
  end
end
