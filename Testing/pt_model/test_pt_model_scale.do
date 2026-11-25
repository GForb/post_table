*The estimate's scale follows the model on every path: comparisons made with lincom
*(three or more arms, each timepoint of pt_model_mt, subgroups) are exponentiated when
*the model reported ratios (e.g. stcox, logistic, logit with or), as the two-arm estimate
*read from the model results table is. And dfmethod(repeated) stops on the lincom paths.
*Expected values are calculated here with lincom; no reference tables.

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

cd "$pt_root/Testing/pt_model"

use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
gen y_bin = y_cont > 11 if y_cont < .
label var y_bin "Binary"
qui levelsof time, local(times)
local t2 : word 2 of `times'
tempfile long_data
save `long_data'
qui levelsof time, local(times)
local t1 : word 1 of `times'
keep if time == `t1'
set seed 77
gen surv_time = rexponential(10 / (1 + arm))
gen surv_event = runiform() < 0.7
tempfile one_time
save `one_time'

*Test 1: three arms after stcox without exp: hazard ratios, as stcox reports them
use `one_time', clear
stset surv_time, failure(surv_event)
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 sum2 est p) using `results', replace
stcox i.arm
pt_model surv_time, postname(`postname') treat(arm) type(skew)
qui lincom 2.arm - 1.arm, eform
fmt_lincom 1
local exp_hr "`r(s)'"
postclose `postname'
use `results', clear
pt_expect est, row(4) value("`exp_hr'") name(pt_model_scale:test1_stcox_three_arms_hr)

*Test 2: the same with exp: not exponentiated twice
use `one_time', clear
stset surv_time, failure(surv_event)
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 sum2 est p) using `results', replace
stcox i.arm
pt_model surv_time, postname(`postname') treat(arm) type(skew) exp
postclose `postname'
use `results', clear
pt_expect est, row(4) value("`exp_hr'") name(pt_model_scale:test2_stcox_exp_once)

*Test 3: pt_model_mt after melogit with or, without exp: odds ratios at each timepoint
use `long_data', clear
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
keep if arm < 2
melogit y_bin i.arm##i.time || pid:, or
pt_model_mt y_bin, postname(`postname') treat(arm) time_var(time) type(bin)
qui lincom 1.arm + 1.arm#`t2'.time, eform
fmt_lincom 1
local exp_or "`r(s)'"
postclose `postname'
use `results', clear
pt_expect est, row(3) value("`exp_or'") name(pt_model_scale:test3_melogit_or_mt)

*Test 4: pt_model_mt after logit without or or exp: log odds ratios, as logit reports them
use `long_data', clear
keep if arm < 2
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
logit y_bin i.arm##i.time
pt_model_mt y_bin, postname(`postname') treat(arm) time_var(time) type(bin)
qui lincom 1.arm + 1.arm#`t2'.time
fmt_lincom 1
local exp_log "`r(s)'"
postclose `postname'
use `results', clear
pt_expect est, row(3) value("`exp_log'") name(pt_model_scale:test4_logit_log_scale)

*Test 5: dfmethod(repeated) stops where lincom is needed, and not on the two-arm path
use `long_data', clear
keep if arm < 2
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
mixed y_cont i.arm##i.time || pid:, reml dfmethod(repeated)
pt_expect_error, name(pt_model_scale:test5_repeated_mt_stops): pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time) type(cont)
postclose `postname'

use `one_time', clear
gen site = mod(pid, 8)
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 sum2 est p) using `results', replace
mixed y_cont i.arm || site:, reml dfmethod(repeated)
pt_expect_error, name(pt_model_scale:test5_repeated_three_arms_stops): pt_model y_cont, postname(`postname') treat(arm) type(cont)
postclose `postname'

keep if arm < 2
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
mixed y_cont i.arm || site:, reml dfmethod(repeated)
cap noisily pt_model y_cont, postname(`postname') treat(arm) type(cont)
pt_record pt_model_scale:test5_repeated_two_arms_runs, rc(`=_rc')
postclose `postname'
