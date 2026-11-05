*Generate data

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

cd "$pt_root/Testing/pt_model"

set seed 100
clear
set obs 300

gen allocation = rbinomial(1, 0.5)

gen y_cont_err = rnormal(0, 3)
gen y_cont = y_cont_err + allocation

gen y_bin = 0
replace y_bin = 1 if y_cont > 0

gen y_count = rpoisson(allocation + 2)

label var y_cont "Continuous"
label var y_bin "Binary"
label var y_count "Poisson"

tempfile test_data
save `test_data'

tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p) using `results' , replace 

post `postname' ("Variable") ("summary group 1")  ("summary group 2") ("est and CI") ("p-value")  

regress y_cont allocation
pt_model y_cont, postname(`postname') treat(allocation) su_label(append)

logit y_bin allocation
pt_model y_bin, postname(`postname') treat(allocation) exp su_label(append)

poisson y_count allocation
pt_model y_count, postname(`postname') treat(allocation) exp  su_label(append)  

poisson y_count allocation, irr

pt_model y_count, postname(`postname') treat(allocation) exp type(skew) su_label(append)


postclose `postname'

use `results', clear
tempfile test1
save `test1', replace
*save pt_model_test1_reference, replace // updates reference data

*With n-analysis cols

use `test_data', clear

tempname postname
tempfile results
postfile `postname'  str60 variable str20(n1 sum1 n2 sum2 est p) using `results' , replace 

post `postname' ("Variable") ("N group 1")  ("N group 2")  ("summary group 1")   ("summary group 2") ("est and CI") ("p-value")  

regress y_cont allocation
pt_model y_cont, postname(`postname') treat(allocation) su_label(append) n_analysis(cols)

logistic y_bin allocation
pt_model y_bin, postname(`postname') treat(allocation)  su_label(append)  n_analysis(cols)


poisson y_count allocation, irr

pt_model y_count, postname(`postname') treat(allocation)  type(skew) su_label(append)  n_analysis(cols)


postclose `postname'

use `results', clear
tempfile test2
save `test2', replace
*save pt_model_test2_reference, replace // updates reference data

forvalues i = 1(1)2 {
	use `test`i'', clear
	pt_check using "pt_model_test`i'_reference.dta", name(pt_model:test`i')
}


*Data for tests 3 and 4: clustered by site, with missing outcome data (made by Testing/make_input_data.do)
local test_data2 "$pt_root/Testing/pt_model/Input data/pt_model_input.dta"
use "`test_data2'", clear

*Test 3: mixed model with icc, missing(cols), per and decimal()
tempname postname
tempfile results
postfile `postname'  str60 variable str20(miss1 miss2 sum1 sum2 est p icc) using `results' , replace

mixed y_cont allocation || site:
pt_model y_cont, postname(`postname') treat(allocation) missing(cols) icc per decimal(2)

qui count if allocation == 0
local denom = r(N)
qui count if !e(sample) & allocation == 0
local exp_miss1 = "`r(N)' (" + string(r(N)/`denom'*100, "%12.2f") + "%)"
qui estat icc
local exp_icc = string(r(icc2), "%3.2f")
postclose `postname'

use `results', clear
pt_check using "pt_model_test3_reference.dta", name(pt_model:test3)
pt_expect miss1, row(1) value("`exp_miss1'") name(pt_model:test3_missing_cols)
pt_expect icc, row(1) value("`exp_icc'") name(pt_model:test3_icc)

*Test 4: p >= 0.01, gap, var_lab, treat_grps order, positive(0), est_decimal, missing(brackets)
use "`test_data2'", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p) using `results' , replace

regress y_null allocation
pt_model y_null, postname(`postname') treat(allocation) gap(1) var_lab("Null outcome") su_label(append)
local exp_p_null = string(2*ttail(e(df_r), abs(_b[allocation]/_se[allocation])), "%3.2f")

logit y_bin allocation
pt_model y_bin, postname(`postname') treat(allocation) treat_grps(1 0) exp per positive(0) su_decimal(2) est_decimal(3)
qui count if e(sample) & allocation == 1
local denom = r(N)
qui count if e(sample) & allocation == 1 & y_bin == 0
local exp_neg_treated = "`r(N)' (" + string(r(N)/`denom'*100, "%12.2f") + "%)"

regress y_cont allocation
pt_model y_cont, postname(`postname') treat(allocation) missing(brackets)
postclose `postname'

use `results', clear
pt_check using "pt_model_test4_reference.dta", name(pt_model:test4)
pt_expect p, row(1) value("`exp_p_null'") name(pt_model:test4_p_two_decimals)
pt_expect sum1, row(3) value("`exp_neg_treated'") name(pt_model:test4_positive0_treat_grps)

*Known bug: append_label() writes the literal text `append_label into the table
use "`test_data2'", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p) using `results' , replace
regress y_cont allocation
pt_model y_cont, postname(`postname') treat(allocation) append_label("(adjusted)")
postclose `postname'
use `results', clear
pt_expect variable, row(1) value("Continuous (adjusted)") name(pt_model:bug_append_label) known_bug

*Test 5: three arms, one row per comparison
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_multiarm_input.dta", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum0 sum1 sum2 est p) using `results' , replace
regress y_cont i.arm
pt_model y_cont, postname(`postname') treat(arm) type(cont)
qui lincom 1.arm
fmt_lincom 1
local exp_est_10 `r(s)'
fmt_p `r(p)'
local exp_p_10 `r(s)'
qui lincom 2.arm
fmt_lincom 1
local exp_est_20 `r(s)'
fmt_p `r(p)'
local exp_p_20 `r(s)'
qui lincom 2.arm - 1.arm
fmt_lincom 1
local exp_est_21 `r(s)'
fmt_p `r(p)'
local exp_p_21 `r(s)'
qui su y_cont if e(sample) & arm == 2
local exp_sum2 = string(r(mean), "%12.1f") + " (" + string(r(sd), "%12.1f") + ")"
postclose `postname'

use `results', clear
pt_check using "pt_model_test5_reference.dta", name(pt_model:test5)
pt_record pt_model:test5_rows, rc(`=_N != 4')
pt_expect sum2, row(1) value("`exp_sum2'") name(pt_model:test5_summary)
pt_expect est, row(1) value("") name(pt_model:test5_no_estimate_on_summary_row)
pt_expect variable, row(2) value("    Low dose vs Control") name(pt_model:test5_label_10)
pt_expect variable, row(4) value("    High dose vs Low dose") name(pt_model:test5_label_21)
local row = 2
foreach pair in 10 20 21 {
	pt_expect est, row(`row') value("`exp_est_`pair''") name(pt_model:test5_est_`pair')
	pt_expect p, row(`row') value("`exp_p_`pair''") name(pt_model:test5_p_`pair')
	local row = `row' + 1
}

*Test 6: compare() with a logistic model and exp, checked against the log scale
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_multiarm_input.dta", clear
gen y_bin = y_cont > 11 if y_cont < .
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum0 sum1 sum2 est p) using `results' , replace
logit y_bin i.arm
pt_model y_bin, postname(`postname') treat(arm) type(bin) exp compare(1v2) gap(1)
qui lincom 1.arm - 2.arm
local exp_or = string(exp(r(estimate)), "%12.1f") + " (" + string(exp(r(lb)), "%12.1f") + ", " + string(exp(r(ub)), "%12.1f") + ")"
fmt_p `r(p)'
local exp_p_or `r(s)'
postclose `postname'
use `results', clear
pt_record pt_model:test6_rows, rc(`=_N != 3')
pt_expect est, row(2) value("`exp_or'") name(pt_model:test6_odds_ratio)
pt_expect p, row(2) value("`exp_p_or'") name(pt_model:test6_p)
pt_expect variable, row(3) value("") name(pt_model:test6_gap)

*Test 7: mixed model, and errors
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum0 sum1 sum2 est p) using `results' , replace
mixed y_cont i.arm || pid:
pt_model y_cont, postname(`postname') treat(arm) type(cont)
qui lincom 2.arm - 1.arm
fmt_lincom 1
local exp_est_mixed `r(s)'
regress y_cont arm
pt_expect_error, name(pt_model:test7_treat_not_factor): pt_model y_cont, postname(`postname') treat(arm) type(cont)
regress y_cont i.arm
pt_expect_error, name(pt_model:test7_compare_bad_format): pt_model y_cont, postname(`postname') treat(arm) type(cont) compare(2 1)
postclose `postname'
use `results', clear
pt_record pt_model:test7_rows, rc(`=_N != 4')
pt_expect est, row(4) value("`exp_est_mixed'") name(pt_model:test7_mixed_est)
