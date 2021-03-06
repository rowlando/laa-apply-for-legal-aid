module Providers
  class CheckProviderAnswersController < ProviderBaseController
    def index
      return redirect_to_means_summary if legal_aid_application.means_completed?

      set_variables
      legal_aid_application.check_your_answers! unless status_change_not_required?
    end

    def reset
      legal_aid_application.reset!
      redirect_to back_path
    end

    def continue
      legal_aid_application.client_details_answers_checked! unless draft_selected?
      continue_or_draft
    end

    private

    def set_variables
      @proceeding_types = legal_aid_application.proceeding_types
      @applicant = legal_aid_application.applicant
      @read_only = legal_aid_application.read_only?
      @address = @applicant.addresses.first
    end

    # This handles the situation where a provider is viewing providers/applications and a citizens completes their
    # journey - causing the link to the application to be out of step with the provider step.
    def redirect_to_means_summary
      redirect_to providers_legal_aid_application_means_summary_path(legal_aid_application)
    end

    def status_change_not_required?
      legal_aid_application.checking_client_details_answers? ||
        legal_aid_application.provider_submitted? ||
        legal_aid_application.checking_citizen_answers?
    end
  end
end
