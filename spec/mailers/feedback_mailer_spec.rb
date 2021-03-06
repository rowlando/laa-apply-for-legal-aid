require 'rails_helper'

RSpec.describe FeedbackMailer, type: :mailer do
  describe 'notify' do
    let(:feedback) { create :feedback }
    let(:mail) { described_class.notify(feedback) }

    it 'sends to correct address' do
      expect(mail.to).to eq([Rails.configuration.x.support_email_address])
    end

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end
  end
end
