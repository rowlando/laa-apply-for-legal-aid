class AddCcmsReferenceNumberToLegalAidApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_aid_applications, :ccms_reference_number, :string
  end
end
