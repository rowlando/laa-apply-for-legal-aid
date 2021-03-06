module Providers
  class TransactionsController < ProviderBaseController
    helper_method :date_from, :date_to

    def show
      authorize legal_aid_application
      transaction_type
      bank_transactions
    end

    def update
      authorize legal_aid_application
      reset_selection
      set_selection
      continue_or_draft
    end

    private

    def date_from
      l(legal_aid_application.transaction_period_start_at.to_date, format: :long_date)
    end

    def date_to
      l(legal_aid_application.transaction_period_finish_at.to_date, format: :long_date)
    end

    def reset_selection
      bank_transactions.where(transaction_type_id: transaction_type.id).update_all(transaction_type_id: nil)
    end

    def set_selection
      bank_transactions
        .where(id: selected_transaction_ids)
        .update_all(transaction_type_id: transaction_type.id)
    end

    def selected_transaction_ids
      params[:transaction_ids].select(&:present?)
    end

    def transaction_type
      @transaction_type ||= TransactionType.find_by(name: params[:transaction_type]) || TransactionType.first
    end

    def bank_transactions
      @bank_transactions ||=
        legal_aid_application
        .bank_transactions
        .where(operation: transaction_type.operation)
        .order(happened_at: :desc, description: :desc)
    end
  end
end
