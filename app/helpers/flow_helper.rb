module FlowHelper
  def next_action_buttons_with_form(
        url:,
        method: :post,
        show_draft: false,
        continue_button_text: t('generic.save_and_continue')
      )

    form_with(model: nil, url: url, method: method, local: true) do |form|
      next_action_buttons(
        show_draft: show_draft,
        form: form,
        continue_button_text: continue_button_text
      )
    end
  end

  def next_action_buttons(
        form:,
        continue_id: :continue,
        show_draft: false,
        continue_button_text: t('generic.save_and_continue')
      )

    render(
      'shared/forms/next_action_buttons',
      continue_id: continue_id,
      form: form,
      show_draft: show_draft,
      continue_button_text: continue_button_text
    )
  end

  def next_action_link(continue_id: :continue, continue_text: t('generic.save_and_continue'))
    link_to(continue_text, forward_path, id: continue_id, class: 'govuk-button govuk-button')
  end
end
