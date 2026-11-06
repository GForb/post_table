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

*append_label() adds text to the row label
use "`test_data2'", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p) using `results' , replace
regress y_cont allocation
pt_model y_cont, postname(`postname') treat(allocation) append_label("(adjusted)")
postclose `postname'
use `results', clear
pt_expect variable, row(1) value("Continuous (adjusted)") name(pt_model:append_label)

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

*Test 8: two arms with treatment as a factor variable give one row, with the same result as without
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_input.dta", clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum0 sum1 est p) using `results' , replace
regress y_cont allocation
pt_model y_cont, postname(`postname') treat(allocation) type(cont)
regress y_cont i.allocation
pt_model y_cont, postname(`postname') treat(allocation) type(cont)
regress y_cont ib1.allocation
pt_model y_cont, postname(`postname') treat(allocation) type(cont)
lincom 0.allocation
fmt_lincom 1
local exp_ib1 "`r(s)'"
logit y_bin allocation
pt_model y_bin, postname(`postname') treat(allocation) type(bin) exp
logit y_bin i.allocation
pt_model y_bin, postname(`postname') treat(allocation) type(bin) exp
postclose `postname'
use `results', clear
pt_record pt_model:test8_rows, rc(`=_N != 5')
local exp_est = est[1]
local exp_p = p[1]
local exp_or = est[4]
local exp_p_or = p[4]
pt_expect est, row(2) value("`exp_est'") name(pt_model:test8_factor_est)
pt_expect p, row(2) value("`exp_p'") name(pt_model:test8_factor_p)
pt_expect est, row(3) value("`exp_ib1'") name(pt_model:test8_reference_arm_est)
pt_expect est, row(5) value("`exp_or'") name(pt_model:test8_factor_odds_ratio)
pt_expect p, row(5) value("`exp_p_or'") name(pt_model:test8_factor_odds_ratio_p)

*Test 9: after mixed with dfmethod(), the factor variable estimate uses small-sample inference
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_input.dta", clear
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
mixed y_cont i.allocation || site:, reml dfmethod(kr)
pt_model y_cont, postname(`postname') treat(allocation) type(cont) est_decimal(4)
mixed y_cont i.allocation || site:, reml dfmethod(kr)
pt_model y_cont, postname(`postname') treat(allocation) type(cont) est_decimal(4) exp
lincom 1.allocation - 0.allocation
fmt_lincom 4
local z_est "`r(s)'"
lincom 1.allocation - 0.allocation, small
fmt_lincom 4
local exp_est "`r(s)'"
fmt_p `r(p)'
local exp_p `r(s)'
lincom 1.allocation - 0.allocation, small eform
local exp_or = string(r(estimate), "%12.4f") + " (" + string(r(lb), "%12.4f") + ", " + string(r(ub), "%12.4f") + ")"
postclose `postname'
use `results', clear
pt_record pt_model:test9_small_differs_from_z, rc(`="`exp_est'" == "`z_est'"')
pt_expect est, row(1) value("`exp_est'") name(pt_model:test9_small_est)
pt_expect p, row(1) value("`exp_p'") name(pt_model:test9_small_p)
pt_expect est, row(2) value("`exp_or'") name(pt_model:test9_small_eform)

*Test 10: two arms: the estimate is the treatment coefficient in the model results table
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_input.dta", clear
set seed 3141
gen ftime = 1 + rexponential(5)
gen event = runiform() > 0.3
stset ftime, failure(event)
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
*row 1: treatment is not the first coefficient
regress y_cont sex allocation
pt_model y_cont, postname(`postname') treat(allocation) type(cont) est_decimal(3)
lincom allocation
fmt_lincom 3
local exp_not_first "`r(s)'"
*row 2: confidence level set in the model
regress y_cont i.allocation, level(90)
pt_model y_cont, postname(`postname') treat(allocation) type(cont) est_decimal(3)
lincom 1.allocation, level(90)
fmt_lincom 3
local exp_level "`r(s)'"
*rows 3 to 5: exp is not applied twice to a table that is already exponentiated
logit y_bin allocation
pt_model y_bin, postname(`postname') treat(allocation) type(bin) est_decimal(3) exp
lincom allocation, eform
fmt_lincom 3
local exp_or "`r(s)'"
logit y_bin allocation, or
pt_model y_bin, postname(`postname') treat(allocation) type(bin) est_decimal(3) exp
logistic y_bin allocation
pt_model y_bin, postname(`postname') treat(allocation) type(bin) est_decimal(3) exp
*rows 6 and 7: scale of the model results table is kept without exp
stcox allocation
pt_model y_cont, postname(`postname') treat(allocation) type(cont) est_decimal(3)
lincom allocation, eform
fmt_lincom 3
local exp_hr "`r(s)'"
stcox i.allocation
pt_model y_cont, postname(`postname') treat(allocation) type(cont) est_decimal(3)
postclose `postname'
use `results', clear
pt_expect est, row(1) value("`exp_not_first'") name(pt_model:test10_treat_not_first)
pt_expect est, row(2) value("`exp_level'") name(pt_model:test10_model_level)
pt_expect est, row(3) value("`exp_or'") name(pt_model:test10_exp_logit)
pt_expect est, row(4) value("`exp_or'") name(pt_model:test10_exp_logit_or)
pt_expect est, row(5) value("`exp_or'") name(pt_model:test10_exp_logistic)
pt_expect est, row(6) value("`exp_hr'") name(pt_model:test10_stcox)
pt_expect est, row(7) value("`exp_hr'") name(pt_model:test10_stcox_factor)

*Test 11: multiple imputation uses the combined results in the model results table
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_input.dta", clear
set seed 2025
replace y_cont = . if runiform() < 0.2
mi set wide
mi register imputed y_cont
mi impute regress y_cont i.allocation sex, add(5) rseed(1)
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
mi estimate: regress y_cont i.allocation sex
mat T = r(table)
local exp_mi = string(T[1,2], "%12.3f") + " (" + string(T[5,2], "%12.3f") + ", " + string(T[6,2], "%12.3f") + ")"
pt_model y_cont, postname(`postname') treat(allocation) type(cont) est_decimal(3)
mi estimate, post: regress y_cont i.allocation sex
pt_model y_cont, postname(`postname') treat(allocation) type(cont) est_decimal(3)
postclose `postname'
use `results', clear
pt_expect est, row(1) value("`exp_mi'") name(pt_model:test11_mi)
pt_expect est, row(2) value("`exp_mi'") name(pt_model:test11_mi_post)

*Test 12: two arms of three, neither the base level, need lincom
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_multiarm_input.dta", clear
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum1 sum2 est p) using `results', replace
regress y_cont i.arm
pt_model y_cont, postname(`postname') treat(arm) treat_grps(1 2) type(cont) est_decimal(3)
lincom 2.arm - 1.arm
fmt_lincom 3
local exp_est "`r(s)'"
postclose `postname'
use `results', clear
pt_expect est, row(1) value("`exp_est'") name(pt_model:test12_no_base_arm)
