$(function () {
  if ($("#bail_conditions_set").length) {
    $(bailConditions).on("change", function () {
      bailConditions();
    });
  };
});

function bailConditions() {
  let optionChecked = "input[type = radio][name = 'respondent[bail_conditions_set]']:checked";
  let optionValue = $(optionChecked).val();
  let bailConditionsLabel = "label[for='bail_conditions_set_details']";

  if (optionValue != 'true') {
    $(bailConditionsLabel).text($('#bail_conditions_set_details').attr('data-bail-conditions-no'));
  } else {
    $(bailConditionsLabel).text($('#bail_conditions_set_details').attr('data-bail-conditions-yes'));
  }
}
