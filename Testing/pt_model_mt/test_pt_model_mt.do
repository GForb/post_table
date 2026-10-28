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

*Known bug: icc stops with r(151) "non r-class program may not set r()"
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_input.dta", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p icc) using `results' , replace
mixed y_cont i.allocation##i.time || pid:
cap noisily pt_model_mt y_cont, postname(`postname') time_var(time) treat(allocation) icc
pt_record pt_model_mt:bug_icc_crashes, rc(`=_rc') known_bug
postclose `postname'
