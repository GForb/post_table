*Tests for pt_subgroup. Each table is compared with a reference file, and key
*cells are also checked against values calculated directly from the data.

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

cd "$pt_root/Testing/pt_subgroup"


*************Programs to generate data and expected values***************
cap prog drop pt_subgroup_data
prog define pt_subgroup_data
	* Input data made by Testing/make_input_data.do
	use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_input.dta", clear
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
*  Test 3: skewed outcome, three-level subgroup, joint interaction test, use_outcome_label
********************************************************************************
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p) using `results', replace

regress y_skew i.allocation##i.agegrp
pt_subgroup y_skew, postname(`postname') sub_var(agegrp) treat(allocation) type(skew) su_label(append) use_outcome_label

qui tabstat y_skew if e(sample) & allocation == 0 & agegrp == 3, stats(q) save
mat Q = r(StatTotal)
local exp_sum0_60 = string(Q[2,1], "%12.1f") + " (" + string(Q[1,1], "%12.1f") + "-" + string(Q[3,1], "%12.1f") + ")"
qui test 1.allocation#2.agegrp 1.allocation#3.agegrp
fmt_p `r(p)'
local exp_p_int `r(s)'
postclose `postname'

use `results', clear
pt_check using "pt_subgroup_test3_reference.dta", name(pt_subgroup:test3)
pt_expect sum0, row(4) value("`exp_sum0_60'") name(pt_subgroup:test3_median_iqr)
pt_expect p, row(1) value("`exp_p_int'") name(pt_subgroup:test3_interaction_p_joint)

* Same joint p-value when the highest subgroup level is the model base
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p) using `results', replace

regress y_skew i.allocation##ib3.agegrp
pt_subgroup y_skew, postname(`postname') sub_var(agegrp) treat(allocation) type(skew) su_label(append) use_outcome_label
postclose `postname'

use `results', clear
pt_expect p, row(1) value("`exp_p_int'") name(pt_subgroup:test3_interaction_p_highest_level_base)


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
*  Test 5: three treatment arms and a three-level subgroup, one block per comparison
********************************************************************************
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_multiarm_input.dta", clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace

regress y_cont i.arm##i.agegrp
pt_subgroup y_cont, postname(`postname') sub_var(agegrp) treat(arm) type(cont) compare(1v0 2v0 2v1)

* Default is every pair, higher arm vs lower arm: row 1 is the title, then a header and three levels per comparison
foreach a in 1 2 {
	foreach k in 1 2 3 {
		qui lincom `a'.arm + `a'.arm#`k'.agegrp
		fmt_lincom 1
		local exp_est_`a'0_`k' `r(s)'
	}
	qui test `a'.arm#2.agegrp `a'.arm#3.agegrp
	local exp_df_`a'0 = r(df)
	fmt_p `r(p)'
	local exp_p_`a'0 `r(s)'
}
foreach k in 1 2 3 {
	qui lincom 2.arm + 2.arm#`k'.agegrp - 1.arm - 1.arm#`k'.agegrp
	fmt_lincom 1
	local exp_est_21_`k' `r(s)'
}
qui test (2.arm#2.agegrp = 1.arm#2.agegrp) (2.arm#3.agegrp = 1.arm#3.agegrp)
local exp_df_21 = r(df)
fmt_p `r(p)'
local exp_p_21 `r(s)'
fmt_meansd y_cont if e(sample) & arm == 0 & agegrp == 2, d(1)
local exp_sum0 `r(s)'
fmt_meansd y_cont if e(sample) & arm == 1 & agegrp == 2, d(1)
local exp_sum1 `r(s)'
fmt_meansd y_cont if e(sample) & arm == 2 & agegrp == 2, d(1)
local exp_sum2 `r(s)'
postclose `postname'

use `results', clear
pt_check using "pt_subgroup_test5_reference.dta", name(pt_subgroup:test5)
pt_record pt_subgroup:test5_rows, rc(`=_N != 13')
pt_expect variable, row(2) value("  Low dose vs Control") name(pt_subgroup:test5_header_10)
pt_expect variable, row(6) value("  High dose vs Control") name(pt_subgroup:test5_header_20)
pt_expect variable, row(10) value("  High dose vs Low dose") name(pt_subgroup:test5_header_21)
local row = 2
foreach pair in 10 20 21 {
	pt_expect p, row(`row') value("`exp_p_`pair''") name(pt_subgroup:test5_interaction_p_`pair')
	foreach k in 1 2 3 {
		pt_expect est, row(`=`row' + `k'') value("`exp_est_`pair'_`k''") name(pt_subgroup:test5_est_`pair'_level`k')
	}
	local row = `row' + 4
}
pt_expect sum0, row(4) value("`exp_sum0'") name(pt_subgroup:test5_summary_arm0)
pt_expect sum1, row(4) value("`exp_sum1'") name(pt_subgroup:test5_summary_arm1)
pt_expect sum2, row(4) value("`exp_sum2'") name(pt_subgroup:test5_summary_arm2)
pt_expect sum0, row(8) value("") name(pt_subgroup:test5_summaries_first_block_only)
pt_record pt_subgroup:test5_interaction_df, rc(`=`exp_df_20' != 2 | `exp_df_21' != 2')

* Results do not depend on the reference arm of the model
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_multiarm_input.dta", clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace
regress y_cont ib2.arm##i.agegrp
pt_subgroup y_cont, postname(`postname') sub_var(agegrp) treat(arm) type(cont) compare(1v0 2v0 2v1)
postclose `postname'
use `results', clear
pt_expect est, row(11) value("`exp_est_21_1'") name(pt_subgroup:test5_reference_arm_est)
pt_expect p, row(10) value("`exp_p_21'") name(pt_subgroup:test5_reference_arm_p)

* compare() chooses the comparisons and their direction, and any arm can be on either side
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_multiarm_input.dta", clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace
regress y_cont i.arm##i.agegrp
pt_subgroup y_cont, postname(`postname') sub_var(agegrp) treat(arm) type(cont) compare(1v2 2v0)
qui lincom 1.arm + 1.arm#3.agegrp - 2.arm - 2.arm#3.agegrp
fmt_lincom 1
local exp_est_12_3 `r(s)'
postclose `postname'
use `results', clear
pt_record pt_subgroup:test5_compare_rows, rc(`=_N != 9')
pt_expect variable, row(2) value("  Low dose vs High dose") name(pt_subgroup:test5_compare_header)
pt_expect est, row(5) value("`exp_est_12_3'") name(pt_subgroup:test5_compare_reversed_est)
pt_expect p, row(2) value("`exp_p_21'") name(pt_subgroup:test5_compare_reversed_p)
pt_expect est, row(7) value("`exp_est_20_1'") name(pt_subgroup:test5_compare_second_est)

* Invalid comparisons, and the removed prim_treat option, stop with an error
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_multiarm_input.dta", clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace
regress y_cont i.arm##i.agegrp
pt_expect_error, name(pt_subgroup:test5_compare_bad_format): pt_subgroup y_cont, postname(`postname') sub_var(agegrp) treat(arm) type(cont) compare(2-1)
pt_expect_error, name(pt_subgroup:test5_compare_same_arm): pt_subgroup y_cont, postname(`postname') sub_var(agegrp) treat(arm) type(cont) compare(2v2)
pt_expect_error, name(pt_subgroup:test5_compare_unknown_arm): pt_subgroup y_cont, postname(`postname') sub_var(agegrp) treat(arm) type(cont) compare(3v1)
pt_expect_error, name(pt_subgroup:test5_prim_treat_removed): pt_subgroup y_cont, postname(`postname') sub_var(agegrp) treat(arm) type(cont) prim_treat(1) compare(1v0 2v0 2v1)
postclose `postname'

* Four arms, all six comparisons, in the order the old default gave them
use "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_multiarm_input.dta", clear
gen arm4 = arm
replace arm4 = 3 if mod(_n, 4) == 0
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 sum3 est p) using `results', replace
regress y_cont i.arm4##i.agegrp
pt_subgroup y_cont, postname(`postname') sub_var(agegrp) treat(arm4) type(cont) compare(1v0 2v0 3v0 2v1 3v1 3v2)
qui lincom 3.arm4 + 3.arm4#1.agegrp - 2.arm4 - 2.arm4#1.agegrp
fmt_lincom 1
local exp_est_32 `r(s)'
postclose `postname'
use `results', clear
pt_record pt_subgroup:test5_four_arms_rows, rc(`=_N != 25')
pt_expect variable, row(22) value("  3 vs 2") name(pt_subgroup:test5_four_arms_no_labels)
pt_expect est, row(23) value("`exp_est_32'") name(pt_subgroup:test5_four_arms_last_est)

* With two arms, compare() can reverse the comparison and adds a header
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p) using `results', replace
regress y_cont i.allocation##i.sex
pt_subgroup y_cont, postname(`postname') sub_var(sex) treat(allocation) compare(0v1)
qui lincom -1.allocation - 1.allocation#2.sex
fmt_lincom 1
local exp_est_01 `r(s)'
postclose `postname'
use `results', clear
pt_record pt_subgroup:test5_two_arms_compare_rows, rc(`=_N != 4')
pt_expect est, row(4) value("`exp_est_01'") name(pt_subgroup:test5_two_arms_compare_est)


********************************************************************************
*  Test 6: sub_var without value labels uses the numeric value as the row label
********************************************************************************
pt_subgroup_data
label values sex
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p) using `results', replace

regress y_cont i.allocation##i.sex
cap noisily pt_subgroup y_cont, postname(`postname') sub_var(sex) treat(allocation)
pt_record pt_subgroup:test6_no_value_labels_runs, rc(`=_rc')

qui lincom 1.allocation + 1.allocation#2.sex
fmt_lincom 1
local exp_est_2 `r(s)'
postclose `postname'

use `results', clear
pt_expect variable, row(2) value("    1  ") name(pt_subgroup:test6_row_label_level1)
pt_expect variable, row(3) value("    2  ") name(pt_subgroup:test6_row_label_level2)
pt_expect est, row(3) value("`exp_est_2'") name(pt_subgroup:test6_est_level2)

* A value label that covers only some levels: the rest use the numeric value
pt_subgroup_data
label define agegrp_part 1 "Youngest"
label values agegrp agegrp_part
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p) using `results', replace
regress y_cont i.allocation##i.agegrp
cap noisily pt_subgroup y_cont, postname(`postname') sub_var(agegrp) treat(allocation)
pt_record pt_subgroup:test6_partial_value_labels_runs, rc(`=_rc')
postclose `postname'

use `results', clear
pt_expect variable, row(2) value("    Youngest  ") name(pt_subgroup:test6_partial_labelled_level)
pt_expect variable, row(3) value("    2  ") name(pt_subgroup:test6_partial_unlabelled_level)


********************************************************************************
*  missing(), per, su_decimal() and icc
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
pt_expect miss0, row(2) value("`exp_miss0_male'") name(pt_subgroup:missing_cols)

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
pt_expect sum0, row(2) value("`exp_sum0_male'") name(pt_subgroup:missing_brackets)

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
pt_expect sum0, row(2) value("`exp_sum0_male'") name(pt_subgroup:per)

*su_decimal(2) gives two decimal places on percentages for binary outcomes
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
pt_expect sum0, row(2) value("`exp_sum0_male'") name(pt_subgroup:binary_su_decimal_2)

*icc posts the icc from the model on the first row only
pt_subgroup_data
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 est p icc) using `results', replace
mixed y_cont i.allocation##i.sex || site:
pt_subgroup y_cont, postname(`postname') sub_var(sex) treat(allocation) icc
qui estat icc
fmt_p `r(icc2)'
local exp_icc `r(s)'
postclose `postname'
use `results', clear
pt_expect icc, row(1) value("`exp_icc'") name(pt_subgroup:icc_value)
pt_expect icc, row(2) value("") name(pt_subgroup:icc_first_row_only)

*after mixed with dfmethod(), estimates and the interaction test use small-sample inference
pt_subgroup_data
keep if site <= 9 // chosen, so the small-sample p-value differs at the reported precision
tempname postname
tempfile results
postfile `postname' str60 variable str40(sum0 sum1 est p) using `results', replace
mixed y_cont i.allocation##i.sex || site:, reml dfmethod(kr)
pt_subgroup y_cont, postname(`postname') sub_var(sex) treat(allocation) type(cont) est_decimal(4)
test (0.allocation#1.sex = 1.allocation#1.sex) (0.allocation#2.sex = 1.allocation#2.sex)
local z_int = r(p)
test (0.allocation#1.sex = 1.allocation#1.sex) (0.allocation#2.sex = 1.allocation#2.sex), small
fmt_p `r(p)'
local exp_int `r(s)'
fmt_p `z_int'
local z_int `r(s)'
lincom 1.allocation + 1.allocation#2.sex, small
fmt_lincom 4
local exp_est "`r(s)'"
postclose `postname'
use `results', clear
pt_record pt_subgroup:small_int_differs_from_z, rc(`="`z_int'" == "`exp_int'"')
pt_expect p, row(1) value("`exp_int'") name(pt_subgroup:small_interaction_p)
pt_expect est, row(3) value("`exp_est'") name(pt_subgroup:small_est)
