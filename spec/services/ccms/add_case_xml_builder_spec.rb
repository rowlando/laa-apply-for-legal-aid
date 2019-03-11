require 'rails_helper'

module CCMS
  RSpec.describe AddCaseXmlBuilder do
    it 'generates XML' do

      text = AddCaseXmlBuilder.new.run
      expect(text).to eq ''
    end
  end
end
