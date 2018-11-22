module Providers
  class CheckYourAnswersController < BaseController
    include Providers::ApplicationDependable
    include Steppable

    def index; end

    def confirm
      legal_aid_application.provider_submit!
      CitizenEmailService.new(legal_aid_application).send_email
      flash[:notice] = 'Application completed. An e-mail will be sent to the citizen.'
      redirect_to next_step_url
    end
  end
end
