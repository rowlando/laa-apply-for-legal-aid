$(document).ready(() => {
  if ($("#bail_conditions_set").length) {
    let bailConditionOptions = "input[type = radio][name = 'respondent[bail_conditions_set]']";
    setBailConditionsLabel();
    $(bailConditionOptions).on("change", setBailConditionsLabel);
    if($('#bail_conditions_set_details-error').length) updateError();
  };

  function setBailConditionsLabel() {
    let bailConditionsLabel = "label[for='bail_conditions_set_details']";
    $(bailConditionsLabel).text($('#bail_conditions_set_details').attr(`data-bail-conditions-${selectedBailOption()}`));
  }

  function selectedBailOption(){
    let optionChecked = "input[type = radio][name = 'respondent[bail_conditions_set]']:checked";
    let optionValue = $(optionChecked).val() == 'false' ? 'no' : 'yes'
    return optionValue
  }

  function updateError(){
    if ($('#bail_conditions_set_details-error').length){
      $('#bail_conditions_set_details-error').text($('#bail_conditions_set_details').attr(`data-bail-conditions-${selectedBailOption()}`));
      updateErrorSummary();
    }
  }

  function updateErrorSummary(){
    let errorSummaryListText = $(document.body.querySelectorAll('*[href="#bail_conditions_set_details"]')[0]);
    errorSummaryListText.text($('#bail_conditions_set_details').attr(`data-bail-conditions-${selectedBailOption()}`));
  }
});
