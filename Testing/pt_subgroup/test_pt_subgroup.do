*Tests for pt_subgroup. Each table is compared with a reference file, and key
*cells are also checked against values calculated directly from the data.

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

cd "$pt_root/Testing/pt_subgroup"


*************Programs to generate data and expected values***************
cap prog drop pt_subgroup_data
prog define pt_subgroup_data
	clear
	set seed 2024
	set obs 400
	gen site = ceil(_n/20)
	gen allocation = rbinomial(1, 0.5)
	gen sex = rbinomial(1, 0.5) + 1
	gen agegrp = 1 + (runiform() > 0.4) + (runiform() > 0.7)
	bysort site: gen u = rnormal(0, 1) if _n == 1
	bysort site: replace u = u[1]
	gen y_cont = 10 + allocation + 0.5*allocation*(sex==2) + u + rnormal(0, 3)
	gen y_bin = y_cont > 11
	gen y_skew = exp(rnormal(1 + 0.3*allocation, 0.8))
	replace y_cont = . if runiform() < 0.1
	replace y_bin = . if missing(y_cont)

	label define sex 1 "Male" 2 "Female"
	label values sex sex
	label define agegrp 1 "18-39" 2 "40-59" 3 "60+"
	label values agegrp agegrp
	label var sex "Sex"
	label var agegrp "Age group"
	label var y_cont "Continuous"
	label var y_bin "Binary"
	label var y_skew "Skewed"
end

cap prog drop fmt_p
prog define fmt_p, rclass
	args p
	if `p' >= 0.01 return local s = string(`p', "%3.2f")
	else if `p' >= 0.001 return local s = string(`p', "%4.3f")
	else return local s "<0.001"
end

cap prog drop fmt_lincom
prog define fmt_lincom, rclass
	* Formats the last lincom result as "est (ll, ul)"
	args d
	local f %12.`d'f
	return local s = string(r(estimate), "`f'") + " (" + string(r(lb), "`f'") + ", " + string(r(ub), "`f'") + ")"
	return local p = r(p)
end

cap prog drop fmt_meansd
prog define fmt_meansd, rclass
	syntax varname if, d(integer)
	qui su `varlist' `if'
	return local s = string(r(mean), "%12.`d'f") + " (" + string(r(sd), "%12.`d'f") + ")"
end


********************************************************************************
*  Test 1: continuous outcome, interaction p-value, n_analysis(cols), su_label(col), gap
********************************************************************************
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(measure n0 n1 sum0 sum1 est p) using `results', replace

regress y_cont i.allocation##i.sex
pt_subgroup y_cont, postname(`postname') sub_var(sex) treat(allocation) n_analysis(cols) su_label(col) gap(1)

qui count if e(sample) & allocation == 0 & sex == 1
local exp_n0_male = r(N)
fmt_meansd y_cont if e(sample) & allocation == 1 & sex == 2, d(1)
local exp_sum1_female `r(s)'
qui lincom 1.allocation
fmt_lincom 1
local exp_est_male `r(s)'
qui lincom 1.allocation + 1.allocation#2.sex
fmt_lincom 1
local exp_est_female `r(s)'
qui lincom 1.allocation#2.sex
fmt_p `r(p)'
local exp_p_int `r(s)'
postclose `postname'

use `results', clear
pt_check using "pt_subgroup_test1_reference.dta", name(pt_subgroup:test1)
pt_expect n0, row(2) value("`exp_n0_male'") name(pt_subgroup:test1_n_male_control)
pt_expect sum1, row(3) value("`exp_sum1_female'") name(pt_subgroup:test1_mean_female_treated)
pt_expect est, row(2) value("`exp_est_male'") name(pt_subgroup:test1_est_male)
pt_expect est, row(3) value("`exp_est_female'") name(pt_subgroup:test1_est_female)
pt_expect p, row(1) value("`exp_p_int'") name(pt_subgroup:test1_interaction_p)


********************************************************************************
*  Test 2: binary outcome, exp, treat_grps order, est_decimal, var_lab
********************************************************************************
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum1 sum0 est p) using `results', replace

logit y_bin i.allocation##i.sex
pt_subgroup y_bin, postname(`postname') sub_var(sex) treat(allocation) treat_grps(1 0) exp est_decimal(2) var_lab("Sex (binary outcome)")

qui count if e(sample) & allocation == 1 & sex == 1
local denom = r(N)
qui count if e(sample) & allocation == 1 & sex == 1 & y_bin == 1
local exp_sum1_male = "`r(N)' (" + string(r(N)/`denom'*100, "%12.1f") + ")"
qui lincom 1.allocation + 1.allocation#2.sex, eform
fmt_lincom 2
local exp_est_female `r(s)'
postclose `postname'

use `results', clear
pt_check using "pt_subgroup_test2_reference.dta", name(pt_subgroup:test2)
pt_expect variable, row(1) value("Sex (binary outcome) ") name(pt_subgroup:test2_var_lab)
pt_expect sum1, row(2) value("`exp_sum1_male'") name(pt_subgroup:test2_percent_male_treated)
pt_expect est, row(3) value("`exp_est_female'") name(pt_subgroup:test2_odds_ratio_female)


********************************************************************************
*  Test 3: skewed outcome, three-level subgroup, prim_sub_grp, use_outcome_label
********************************************************************************
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p) using `results', replace

regress y_skew i.allocation##i.agegrp
pt_subgroup y_skew, postname(`postname') sub_var(agegrp) treat(allocation) type(skew) su_label(append) use_outcome_label prim_sub_grp(2)

qui tabstat y_skew if e(sample) & allocation == 0 & agegrp == 3, stats(q) save
mat Q = r(StatTotal)
local exp_sum0_60 = string(Q[2,1], "%12.1f") + " (" + string(Q[1,1], "%12.1f") + "-" + string(Q[3,1], "%12.1f") + ")"
qui lincom 1.allocation#2.agegrp
fmt_p `r(p)'
local exp_p_int `r(s)'
postclose `postname'

use `results', clear
pt_check using "pt_subgroup_test3_reference.dta", name(pt_subgroup:test3)
pt_expect sum0, row(4) value("`exp_sum0_60'") name(pt_subgroup:test3_median_iqr)
pt_expect p, row(1) value("`exp_p_int'") name(pt_subgroup:test3_interaction_p_prim_sub_grp)


********************************************************************************
*  Test 4: int_test_false gives a p-value per subgroup; sub_grps sets the row order
********************************************************************************
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p) using `results', replace

regress y_cont i.allocation##i.sex
pt_subgroup y_cont, postname(`postname') sub_var(sex) treat(allocation) int_test_false sub_grps(2 1)

qui lincom 1.allocation + 1.allocation#2.sex
fmt_p `r(p)'
local exp_p_female `r(s)'
postclose `postname'

use `results', clear
pt_check using "pt_subgroup_test4_reference.dta", name(pt_subgroup:test4)
pt_expect variable, row(2) value("    Female  ") name(pt_subgroup:test4_row_order)
pt_expect p, row(2) value("`exp_p_female'") name(pt_subgroup:test4_p_female)


********************************************************************************
*  Known bugs: these check the correct output and are expected to fail for now
********************************************************************************

*missing(cols) should give the number (%) excluded from the analysis in each subgroup
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(miss0 miss1 sum0 sum1 est p) using `results', replace
regress y_cont i.allocation##i.sex
pt_subgroup y_cont, postname(`postname') sub_var(sex) treat(allocation) missing(cols)
qui count if allocation == 0 & sex == 1
local denom = r(N)
qui count if !e(sample) & allocation == 0 & sex == 1
local exp_miss0_male = "`r(N)' (" + string(r(N)/`denom'*100, "%12.1f") + ")"
postclose `postname'
use `results', clear
pt_expect miss0, row(2) value("`exp_miss0_male'") name(pt_subgroup:bug_missing_cols_always_zero) known_bug

*missing(brackets) should add the number missing to each summary
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p) using `results', replace
regress y_cont i.allocation##i.sex
pt_subgroup y_cont, postname(`postname') sub_var(sex) treat(allocation) missing(brackets)
fmt_meansd y_cont if e(sample) & allocation == 0 & sex == 1, d(1)
local exp_sum0_male `r(s)'
qui count if !e(sample) & allocation == 0 & sex == 1
local exp_sum0_male "`exp_sum0_male' [`r(N)']"
postclose `postname'
use `results', clear
pt_expect sum0, row(2) value("`exp_sum0_male'") name(pt_subgroup:bug_missing_brackets_always_zero) known_bug

*per should add a % sign to percentages
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p) using `results', replace
logit y_bin i.allocation##i.sex
pt_subgroup y_bin, postname(`postname') sub_var(sex) treat(allocation) exp per
qui count if e(sample) & allocation == 0 & sex == 1
local denom = r(N)
qui count if e(sample) & allocation == 0 & sex == 1 & y_bin == 1
local exp_sum0_male = "`r(N)' (" + string(r(N)/`denom'*100, "%12.1f") + "%)"
postclose `postname'
use `results', clear
pt_expect sum0, row(2) value("`exp_sum0_male'") name(pt_subgroup:bug_per_ignored) known_bug

*su_decimal(2) or more gives an empty percentage for binary outcomes, e.g. "50 ()"
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p) using `results', replace
logit y_bin i.allocation##i.sex
pt_subgroup y_bin, postname(`postname') sub_var(sex) treat(allocation) exp su_decimal(2)
qui count if e(sample) & allocation == 0 & sex == 1
local denom = r(N)
qui count if e(sample) & allocation == 0 & sex == 1 & y_bin == 1
local exp_sum0_male = "`r(N)' (" + string(r(N)/`denom'*100, "%12.2f") + ")"
postclose `postname'
use `results', clear
pt_expect sum0, row(2) value("`exp_sum0_male'") name(pt_subgroup:bug_binary_su_decimal_2) known_bug

*icc stops with r(151) "non r-class program may not set r()"
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p icc) using `results', replace
mixed y_cont i.allocation##i.sex || site:
cap noisily pt_subgroup y_cont, postname(`postname') sub_var(sex) treat(allocation) icc
pt_record pt_subgroup:bug_icc_crashes, rc(`=_rc') known_bug
postclose `postname'
