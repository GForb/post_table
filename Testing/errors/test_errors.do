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

*Three or more arms need compare(); two arms don't
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace
regress y_cont i.arm##i.time
pt_expect_error, name(errors:pt_model_mt_three_arms_no_compare): pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time)
keep if time == 1
regress y_cont i.arm
pt_expect_error, name(errors:pt_model_three_arms_no_compare): pt_model y_cont, postname(`postname') treat(arm)
pt_expect_error, name(errors:pt_model_three_arms_no_compare_descriptive): pt_model y_cont, postname(`postname') treat(arm) descriptive
postclose `postname'

*A plain treatment variable whose arms are not one apart stops; one apart or i. runs
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
keep if time == 1 & arm < 2
gen arm02 = arm * 2
gen arm12 = arm + 1
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p) using `results', replace
regress y_cont arm02
pt_expect_error, name(errors:pt_model_plain_treat_gap_2): pt_model y_cont, postname(`postname') treat(arm02)
regress y_cont i.arm02
cap noisily pt_model y_cont, postname(`postname') treat(arm02)
pt_record errors:pt_model_factor_treat_gap_2_runs, rc(`=_rc')
regress y_cont arm12
cap noisily pt_model y_cont, postname(`postname') treat(arm12)
pt_record errors:pt_model_plain_treat_gap_1_runs, rc(`=_rc')
postclose `postname'
