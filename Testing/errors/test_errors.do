*Checks that invalid input stops with an error rather than producing a table

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

use "$pt_root/Examples/Creating comprehensive examples/eg_data2", clear
tempname postname
tempfile results
postfile `postname' str100(col1 col2 col3) using `results', replace

pt_expect_error, name(errors:pt_base_no_postname): pt_base age
pt_expect_error, name(errors:pt_sum_no_stats): pt_sum age, postname(`postname')
pt_expect_error, name(errors:pt_model_mt_no_time_var): pt_model_mt age, postname(`postname')

*An invalid stats() stops with an error
pt_expect_error, name(errors:pt_sum_invalid_stats): pt_sum age, postname(`postname') stats(foo)

*pt_model needs the treatment coefficient in the model results table
regress age bmi
pt_expect_error, name(errors:pt_model_treat_not_in_model): pt_model age, postname(`postname') treat(treat)
regress age treat
summarize age
pt_expect_error, name(errors:pt_model_results_lost): pt_model age, postname(`postname') treat(treat)

postclose `postname'
