$(document).ready(() => {
  if ($("#bail_conditions_set").length) {
    let bailConditionOptions = "input[type = radio][name = 'respondent[bail_conditions_set]']";
    // set the correct bail condition label when page is refreshed
    setBailConditionsLabel();
    $(bailConditionOptions).on("change", setBailConditionsLabel);
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
});
