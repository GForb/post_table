*Convergence check (pt_check_converged): pt_model, pt_subgroup and pt_model_mt stop with
*r(430) if the last model did not converge (e(converged) is 0), unless noconvergencecheck
*is given. Models that don't iterate (regress) leave e(converged) empty and pass.
*Non-convergence is forced with iterate(1). No reference tables: the tests check whether
*each command stops or runs.

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

cd "$pt_root/Testing/pt_model"

use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
keep if arm < 2
qui summarize y_cont, detail
gen y_bin = y_cont > r(p50)
qui levelsof time, local(times)
local t1 : word 1 of `times'
local t2 : word 2 of `times'
tempfile long_data
save `long_data'
keep if time == `t1'
tempfile one_time
save `one_time'

*Test 1: pt_model after a model that did not converge: stops with r(430)
use `one_time', clear
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
logit y_bin i.arm, iterate(1)
cap noisily pt_model y_bin, postname(`postname') treat(arm) type(bin) exp
pt_record pt_model_converged:test1_stops_r430, rc(`=_rc != 430')

*Test 2: noconvergencecheck posts the results
logit y_bin i.arm, iterate(1)
cap noisily pt_model y_bin, postname(`postname') treat(arm) type(bin) exp noconvergencecheck
pt_record pt_model_converged:test2_override_runs, rc(`=_rc')

*Test 3: a converged model passes
logit y_bin i.arm
cap noisily pt_model y_bin, postname(`postname') treat(arm) type(bin) exp
pt_record pt_model_converged:test3_converged_runs, rc(`=_rc')

*Test 4: regress leaves e(converged) empty, which passes
regress y_cont i.arm
cap noisily pt_model y_cont, postname(`postname') treat(arm) type(cont)
pt_record pt_model_converged:test4_regress_runs, rc(`=_rc')

*Test 5: descriptive mode doesn't check the last model
logit y_bin i.arm, iterate(1)
cap noisily pt_model y_cont, postname(`postname') treat(arm) type(cont) descriptive
pt_record pt_model_converged:test5_descriptive_runs, rc(`=_rc')
postclose `postname'

*Test 6: pt_model_mt after a model that did not converge: stops; runs with noconvergencecheck
use `long_data', clear
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
logit y_bin i.time##i.arm, iterate(1)
cap noisily pt_model_mt y_bin, postname(`postname') treat(arm) time_var(time) type(bin) exp
pt_record pt_model_converged:test6_mt_stops_r430, rc(`=_rc != 430')
logit y_bin i.time##i.arm, iterate(1)
cap noisily pt_model_mt y_bin, postname(`postname') treat(arm) time_var(time) type(bin) exp noconvergencecheck
pt_record pt_model_converged:test6_mt_override_runs, rc(`=_rc')
postclose `postname'

*Test 7: pt_subgroup after a model that did not converge: stops; runs with noconvergencecheck
use `long_data', clear
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
logit y_bin i.time##i.arm, iterate(1)
cap noisily pt_subgroup y_bin, postname(`postname') treat(arm) sub_var(time) type(bin) exp
pt_record pt_model_converged:test7_subgroup_stops_r430, rc(`=_rc != 430')
logit y_bin i.time##i.arm, iterate(1)
cap noisily pt_subgroup y_bin, postname(`postname') treat(arm) sub_var(time) type(bin) exp noconvergencecheck
pt_record pt_model_converged:test7_subgroup_override_runs, rc(`=_rc')
postclose `postname'
