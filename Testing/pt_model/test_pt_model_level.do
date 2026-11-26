*level(): the confidence level of every estimate, default as set by set level. The
*commands stop if it differs from the model's level, unless nolevelcheck is given; then
*the two-arm interval is worked out again from the model results table at level().
*Expected values are calculated here with lincom or by refitting; no reference tables.

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

cd "$pt_root/Testing/pt_model"

use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
qui levelsof time, local(times)
local t1 : word 1 of `times'
local t2 : word 2 of `times'
tempfile long_data
save `long_data'
keep if time == `t1'
set seed 78
gen surv_time = rexponential(10 / (1 + arm))
gen surv_event = runiform() < 0.7
tempfile one_time
save `one_time'

*Test 1: model at 90%, command at the default: stops, and says so
use `one_time', clear
keep if arm < 2
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
regress y_cont i.arm, level(90)
pt_expect_error, name(pt_model_level:test1_mismatch_stops): pt_model y_cont, postname(`postname') treat(arm) type(cont)
postclose `postname'

*Test 2: three arms, model and command at 90%: lincom at 90%
use `one_time', clear
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 sum2 est p) using `results', replace
regress y_cont i.arm, level(90)
pt_model y_cont, postname(`postname') treat(arm) type(cont) level(90) est_decimal(3) compare(1v0 2v0 2v1)
qui lincom 2.arm - 1.arm, level(90)
fmt_lincom 3
local exp_90 "`r(s)'"
postclose `postname'
use `results', clear
pt_expect est, row(4) value("`exp_90'") name(pt_model_level:test2_three_arms_90)

*Test 3: nolevelcheck, two arms: the interval is worked out again at level()
use `one_time', clear
keep if arm < 2
regress y_cont i.arm, level(80)
mat R = r(table)
local exp_80 = string(R[1, 2], "%12.3f") + " (" + string(R[5, 2], "%12.3f") + ", " + string(R[6, 2], "%12.3f") + ")"
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
regress y_cont i.arm
pt_model y_cont, postname(`postname') treat(arm) type(cont) level(80) nolevelcheck est_decimal(3)
postclose `postname'
use `results', clear
pt_expect est, row(1) value("`exp_80'") name(pt_model_level:test3_two_arms_recomputed)

*Test 4: nolevelcheck after stcox (an exponentiated table): ratio interval at level()
use `one_time', clear
keep if arm < 2
stset surv_time, failure(surv_event)
stcox i.arm, level(90)
mat R = r(table)
local exp_hr90 = string(R[1, 2], "%12.3f") + " (" + string(R[5, 2], "%12.3f") + ", " + string(R[6, 2], "%12.3f") + ")"
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
stcox i.arm
pt_model surv_time, postname(`postname') treat(arm) type(skew) level(90) nolevelcheck est_decimal(3)
postclose `postname'
use `results', clear
pt_expect est, row(1) value("`exp_hr90'") name(pt_model_level:test4_stcox_recomputed)

*Test 5: pt_model_mt: model at 80% needs level(80); then each timepoint uses it
use `long_data', clear
keep if arm < 2
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
mixed y_cont i.arm##i.time || pid:, level(80)
pt_expect_error, name(pt_model_level:test5_mt_mismatch_stops): pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time) type(cont)
pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time) type(cont) level(80) est_decimal(3)
qui lincom 1.arm + 1.arm#`t2'.time, level(80)
fmt_lincom 3
local exp_mt80 "`r(s)'"
postclose `postname'
use `results', clear
pt_expect est, row(3) value("`exp_mt80'") name(pt_model_level:test5_mt_80)

*Test 6: no false alarms at matching levels: Kenward-Roger, multiple imputation, melogit
use `long_data', clear
keep if arm < 2
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
mixed y_cont i.arm##i.time || pid:, reml dfmethod(kr) level(90)
cap noisily pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time) type(cont) level(90)
pt_record pt_model_level:test6_kr_90, rc(`=_rc')
gen y_bin = y_cont > 11 if y_cont < .
melogit y_bin i.arm##i.time || pid:
cap noisily pt_model_mt y_bin, postname(`postname') treat(arm) time_var(time) type(bin) exp
pt_record pt_model_level:test6_melogit_default, rc(`=_rc')
postclose `postname'

use `one_time', clear
keep if arm < 2
set seed 9
replace y_cont = . if runiform() < 0.2
mi set wide
mi register imputed y_cont
mi impute regress y_cont i.arm, add(5) rseed(1)
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
mi estimate, post level(90): regress y_cont i.arm
cap noisily pt_model y_cont, postname(`postname') treat(arm) type(cont) level(90)
pt_record pt_model_level:test6_mi_90, rc(`=_rc')
mi estimate, post: regress y_cont i.arm
cap noisily pt_model y_cont, postname(`postname') treat(arm) type(cont)
pt_record pt_model_level:test6_mi_default, rc(`=_rc')
postclose `postname'

*Test 7: descriptive rows ignore the model's level
use `one_time', clear
regress y_cont i.arm, level(90)
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 sum2 est p) using `results', replace
cap noisily pt_model y_cont, postname(`postname') treat(arm) type(cont) descriptive compare(1v0 2v0 2v1)
pt_record pt_model_level:test7_descriptive_no_check, rc(`=_rc')
postclose `postname'
