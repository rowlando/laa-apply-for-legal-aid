require 'rails_helper'

RSpec.describe ProceedingType, type: :model do
  let!(:proceeding_type) { ProceedingType.create(code: 'PH0001') }

  it 'proceeding_type should have code' do
    expect(proceeding_type.code).not_to be_nil
  end

  describe 'should have associations with legal_aid_application' do
    it { should have_many(:legal_aid_applications) }
  end
end
