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


*Data for tests 3 and 4: clustered by site, with missing outcome data
set seed 2024
clear
set obs 400
gen site = ceil(_n/20)
gen allocation = rbinomial(1, 0.5)
bysort site: gen u = rnormal(0, 1) if _n == 1
bysort site: replace u = u[1]
gen y_cont = 10 + allocation + u + rnormal(0, 3)
gen y_bin = y_cont > 11
gen y_null = rnormal(0, 1)
replace y_cont = . if runiform() < 0.1
replace y_bin = . if missing(y_cont)
label var y_cont "Continuous"
label var y_bin "Binary"
label var y_null "Null"
tempfile test_data2
save `test_data2'

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
use `test_data2', clear
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
use `test_data2', clear
tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p) using `results' , replace
regress y_cont allocation
pt_model y_cont, postname(`postname') treat(allocation) append_label("(adjusted)")
postclose `postname'
use `results', clear
pt_expect variable, row(1) value("Continuous (adjusted)") name(pt_model:bug_append_label) known_bug
