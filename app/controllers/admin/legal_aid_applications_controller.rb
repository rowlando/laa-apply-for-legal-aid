module Admin
  class LegalAidApplicationsController < ApplicationController
    before_action :authenticate_admin_user!
    def index
      @applications = LegalAidApplication.latest.limit(25)
    end

    def destroy_all
      raise 'Legal Aid Application Destroy All action disabled' unless destroy_enabled?

      LegalAidApplication.destroy_all
      Applicant.destroy_all
      redirect_to action: :index
    end

    protected

    # Note this action uses the mock_saml setting to determine if it should be enabled
    def destroy_enabled?
      Rails.configuration.x.admin_portal.allow_reset
    end
    helper_method :destroy_enabled?
  end
end