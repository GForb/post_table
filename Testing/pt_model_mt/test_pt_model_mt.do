*Generate data

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

cd "$pt_root/Testing/pt_model_mt"

set seed 100
clear
local n_obs  1000
set obs `n_obs'

gen pid = _n
gen allocation = rbinomial(1, 0.5)

expand 2


gen time = round(_n/`n_obs')
replace time = time + 1
sort pid time

gen y_cont_err = rnormal(0, 3)
gen y_cont = y_cont_err + allocation + time/3

gen y_bin = 0
replace y_bin = 1 if y_cont > 0

gen y_count = rpoisson(allocation + 2 + time/3)

label var y_cont "Test Continuous Outcome"
label var y_bin "Binary"
label var y_count "Poisson"

tempfile test_data

label define time 1 "Time 1" 2 "Time 2" 3 "Time 3"
label values time time
save `test_data'

tempname postname
tempfile results
postfile `postname'  str60 variable str20(n1 n2 sum1 sum2 est p) using `results' , replace 

post `postname' ("Variable") ("N1") ("N2") ("summary group 1")  ("summary group 2") ("est and CI") ("p-value")  

mixed y_cont  i.allocation##i.time || pid:

pt_model_mt y_cont, postname(`postname') time_var(time) treat(allocation) decimal(2) n_analysis(cols) 

levelsof time, local(time_values)
local first = 1
foreach t in `time_values' {
if `first' {
		lincom 1.allocation
	}
	else {
		lincom 1.allocation + 1.allocation#`t'.time - 0.allocation#`t'.time
	}
	local first = 0
}




postclose `postname'

use `results', clear

pt_check using "Test Data/pt_model_mt_test_data.dta", name(pt_model_mt:test1)

*Test 2: binary outcome, exp, timepoints sets the row order
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_input.dta", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p) using `results' , replace

melogit y_bin i.allocation##i.time || pid:
pt_model_mt y_bin, postname(`postname') time_var(time) treat(allocation) exp timepoints(3 2 1)

qui lincom 1.allocation + 1.allocation#3.time, eform
local exp_est_t3 = string(r(estimate), "%12.1f") + " (" + string(r(lb), "%12.1f") + ", " + string(r(ub), "%12.1f") + ")"
postclose `postname'

use `results', clear
pt_check using "pt_model_mt_test2_reference.dta", name(pt_model_mt:test2)
pt_expect est, row(2) value("`exp_est_t3'") name(pt_model_mt:test2_odds_ratio_time3)

*Test 3: skewed outcome, su_label(append), var_lab, gap, est_decimal
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_input.dta", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p) using `results' , replace

mixed y_count i.allocation##i.time || pid:
pt_model_mt y_count, postname(`postname') time_var(time) treat(allocation) type(skew) su_label(append) var_lab("Count (skewed)") gap(1) est_decimal(2)

qui tabstat y_count if e(sample) & allocation == 1 & time == 2, stats(q) save
mat Q = r(StatTotal)
local exp_sum2_t2 = string(Q[2,1], "%12.1f") + " (" + string(Q[1,1], "%12.1f") + "-" + string(Q[3,1], "%12.1f") + ")"
postclose `postname'

use `results', clear
pt_check using "pt_model_mt_test3_reference.dta", name(pt_model_mt:test3)
pt_expect sum2, row(3) value("`exp_sum2_t2'") name(pt_model_mt:test3_median_iqr)

*Test 4: time variable without value labels, after mixed
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_input.dta", clear
label values time
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p) using `results' , replace
mixed y_cont i.allocation##i.time || pid:
cap noisily pt_model_mt y_cont, postname(`postname') time_var(time) treat(allocation)
pt_record pt_model_mt:test4_no_value_labels_runs, rc(`=_rc')
qui levelsof time, local(time_values)
local t1 : word 1 of `time_values'
local t2 : word 2 of `time_values'
postclose `postname'

use `results', clear
pt_expect variable, row(2) value("    `t1'  ") name(pt_model_mt:test4_row_label_first)
pt_expect variable, row(3) value("    `t2'  ") name(pt_model_mt:test4_row_label_second)

*icc posts the icc from the model on the first row only
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_input.dta", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p icc) using `results' , replace
mixed y_cont i.allocation##i.time || pid:
pt_model_mt y_cont, postname(`postname') time_var(time) treat(allocation) icc
qui estat icc
fmt_p `r(icc2)'
local exp_icc `r(s)'
postclose `postname'
use `results', clear
pt_expect icc, row(1) value("`exp_icc'") name(pt_model_mt:icc_value)
pt_expect icc, row(2) value("") name(pt_model_mt:icc_first_row_only)

*Test 5: three arms, one block per comparison
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum0 sum1 sum2 est p) using `results' , replace
mixed y_cont i.arm##i.time || pid:
pt_model_mt y_cont, postname(`postname') time_var(time) treat(arm) type(cont)
foreach k in 1 2 {
	qui lincom 2.arm + 2.arm#`k'.time - 1.arm - 1.arm#`k'.time
	fmt_lincom 1
	local exp_est_`k' `r(s)'
	fmt_p `r(p)'
	local exp_p_`k' `r(s)'
}
postclose `postname'
use `results', clear
pt_check using "pt_model_mt_test5_reference.dta", name(pt_model_mt:test5)
pt_record pt_model_mt:test5_rows, rc(`=_N != 10')
pt_expect variable, row(8) value("  High dose vs Low dose") name(pt_model_mt:test5_header)
pt_expect est, row(9) value("`exp_est_1'") name(pt_model_mt:test5_est_time1)
pt_expect est, row(10) value("`exp_est_2'") name(pt_model_mt:test5_est_time2)
pt_expect p, row(10) value("`exp_p_2'") name(pt_model_mt:test5_p_time2)
pt_expect p, row(8) value("") name(pt_model_mt:test5_no_interaction_p)

*Test 6: compare() is passed through to pt_subgroup
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum0 sum1 sum2 est p) using `results' , replace
mixed y_cont i.arm##i.time || pid:
pt_model_mt y_cont, postname(`postname') time_var(time) treat(arm) type(cont) compare(2v1)
postclose `postname'
use `results', clear
pt_record pt_model_mt:test6_rows, rc(`=_N != 4')
pt_expect est, row(3) value("`exp_est_1'") name(pt_model_mt:test6_est_time1)

*Test 7: missing(), per and icc with three arms, where only the first block has summaries
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(miss0 miss1 miss2 sum0 sum1 sum2 est p icc) using `results' , replace
mixed y_cont i.arm##i.time || pid:
pt_model_mt y_cont, postname(`postname') time_var(time) treat(arm) type(cont) missing(cols) per icc
qui count if arm == 1 & time == 2
local denom = r(N)
qui count if !e(sample) & arm == 1 & time == 2
local exp_miss1 = "`r(N)' (" + string(r(N)/`denom'*100, "%12.1f") + "%)"
qui estat icc
fmt_p `r(icc2)'
local exp_icc `r(s)'
postclose `postname'
use `results', clear
pt_expect miss1, row(4) value("`exp_miss1'") name(pt_model_mt:test7_missing_cols_per)
pt_expect miss1, row(7) value("") name(pt_model_mt:test7_missing_first_block_only)
pt_expect icc, row(1) value("`exp_icc'") name(pt_model_mt:test7_icc)
pt_expect icc, row(2) value("") name(pt_model_mt:test7_icc_first_row_only)

*Test 8: per and su_decimal() on a binary outcome
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
gen y_bin = y_cont > 11 if y_cont < .
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum0 sum1 sum2 est p) using `results' , replace
logit y_bin i.arm##i.time
pt_model_mt y_bin, postname(`postname') time_var(time) treat(arm) type(bin) exp per su_decimal(2)
qui count if e(sample) & arm == 2 & time == 1
local denom = r(N)
qui count if e(sample) & arm == 2 & time == 1 & y_bin == 1
local exp_sum2 = "`r(N)' (" + string(r(N)/`denom'*100, "%12.2f") + "%)"
postclose `postname'
use `results', clear
pt_expect sum2, row(3) value("`exp_sum2'") name(pt_model_mt:test8_per_su_decimal)

*Test 9: after mixed with dfmethod(), estimates use small-sample inference
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
keep if arm < 2
tempname postname
tempfile results
postfile `postname'  str60 variable str40(sum0 sum1 est p) using `results' , replace
mixed y_cont i.arm##i.time || pid:, reml dfmethod(kr)
pt_model_mt y_cont, postname(`postname') time_var(time) treat(arm) type(cont) est_decimal(4)
lincom 1.arm + 1.arm#2.time
fmt_lincom 4
local z_est "`r(s)'"
lincom 1.arm + 1.arm#2.time, small
fmt_lincom 4
local exp_est "`r(s)'"
fmt_p `r(p)'
local exp_p `r(s)'
postclose `postname'
use `results', clear
pt_record pt_model_mt:test9_small_differs_from_z, rc(`="`exp_est'" == "`z_est'"')
pt_expect est, row(3) value("`exp_est'") name(pt_model_mt:test9_small_est)
pt_expect p, row(3) value("`exp_p'") name(pt_model_mt:test9_small_p)
