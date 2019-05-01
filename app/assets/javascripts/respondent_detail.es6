$(function () {
  if ($("#bail_conditions_set").length) { 
    let bailConditions = "input[type=radio][name='respondent[bail_conditions_set]']";
    $(bailConditions).on("change", function () {
      respondentDetail(bailConditions);
    });
  };
});

function respondentDetail(optionName) {
  let optionChecked = optionName + ':checked';
  let radioButtonValue = $(optionChecked).val();
  let bailConditionsLabel = "label[for='bail_conditions_set_details']";
  if (radioButtonValue != 'true') {
    $(bailConditionsLabel).text($('#understands_terms_of_court_order_details').attr('data-bail-conditions-no'));
  } else {
    $(bailConditionsLabel).text("Give details of the bail conditions, including the date they're likely to end");
  }
}
