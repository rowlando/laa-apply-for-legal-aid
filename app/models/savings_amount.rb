class SavingsAmount < ApplicationRecord
  include Capital

  belongs_to :legal_aid_application
end
