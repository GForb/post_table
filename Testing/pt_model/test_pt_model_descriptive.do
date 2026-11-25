*Tests for the descriptive option of pt_model and pt_model_mt, and for the check that
*the outcome passed is the outcome of the last model (pt_check_depvar).
*Expected values are calculated here, independently of post_table; no reference tables.

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

cd "$pt_root/Testing/pt_model"

*Data: three arms, two timepoints (long), plus a categorical outcome with value labels
use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
set seed 2611
gen y_cat = runiformint(1, 4)
replace y_cat = . if runiform() < 0.1
label define y_cat 1 "None" 2 "Mild" 3 "Moderate" 4 "Severe"
label values y_cat y_cat
label var y_cat "Severity"
gen y_bin = y_cont > 11 if y_cont < .
label var y_bin "Binary"
qui levelsof arm, local(arms)
local a1 : word 1 of `arms'
local a2 : word 2 of `arms'
local a3 : word 3 of `arms'
qui levelsof time, local(times)
local t1 : word 1 of `times'
local t2 : word 2 of `times'
tempfile long_data
save `long_data'

*Same data, first timepoint only (one row per participant)
keep if time == `t1'
tempfile one_time
save `one_time'

*Test 1: two arms, continuous, no model in memory: summaries, empty estimate and p-value
use `one_time', clear
keep if arm != `a3'
ereturn clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum1 sum2 est p) using `results', replace
cap noisily pt_model y_cont, postname(`postname') treat(arm) type(cont) descriptive
pt_record pt_model_desc:test1_runs_without_model, rc(`=_rc')
qui su y_cont if arm == `a2'
local exp_sum2 = string(r(mean), "%12.1f") + " (" + string(r(sd), "%12.1f") + ")"
postclose `postname'
use `results', clear
pt_record pt_model_desc:test1_one_row, rc(`=_N != 1')
pt_expect sum2, row(1) value("`exp_sum2'") name(pt_model_desc:test1_mean_sd)
pt_expect est, row(1) value("") name(pt_model_desc:test1_est_empty)
pt_expect p, row(1) value("") name(pt_model_desc:test1_p_empty)

*Test 2: a model for another outcome in memory doesn't matter in descriptive mode
use `one_time', clear
keep if arm != `a3'
regress y_bin i.arm
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum1 sum2 est p) using `results', replace
cap noisily pt_model y_cont, postname(`postname') treat(arm) type(cont) descriptive
pt_record pt_model_desc:test2_ignores_last_model, rc(`=_rc')
postclose `postname'

*Test 3: binary with per, and skewed
use `one_time', clear
keep if arm != `a3'
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum1 sum2 est p) using `results', replace
pt_model y_bin, postname(`postname') treat(arm) type(bin) per descriptive
pt_model y_cont, postname(`postname') treat(arm) type(skew) descriptive
qui count if arm == `a1' & y_bin < .
local denom = r(N)
qui count if arm == `a1' & y_bin == 1
local exp_bin = "`r(N)' (" + string(r(N) / `denom' * 100, "%12.1f") + "%)"
qui tabstat y_cont if arm == `a1', stats(q) save
mat Q = r(StatTotal)
local exp_skew = string(Q[2,1], "%12.1f") + " (" + string(Q[1,1], "%12.1f") + "-" + string(Q[3,1], "%12.1f") + ")"
postclose `postname'
use `results', clear
pt_expect sum1, row(1) value("`exp_bin'") name(pt_model_desc:test3_binary_per)
pt_expect sum1, row(2) value("`exp_skew'") name(pt_model_desc:test3_skew)
pt_expect est, row(2) value("") name(pt_model_desc:test3_est_empty)

*Test 4: three arms: one row, no comparison rows, empty icc; n_analysis and missing columns
use `one_time', clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(n0 n1 n2 m0 m1 m2 sum0 sum1 sum2 est p icc) using `results', replace
pt_model y_cont, postname(`postname') treat(arm) type(cont) n_analysis(cols) missing(cols) icc descriptive
qui count if arm == `a2' & y_cont < .
local exp_n1 = r(N)
qui count if arm == `a2'
local denom = r(N)
qui count if arm == `a2' & y_cont == .
local exp_m1 = "`r(N)' (" + string(r(N) / `denom' * 100, "%12.1f") + ")"
postclose `postname'
use `results', clear
pt_record pt_model_desc:test4_one_row, rc(`=_N != 1')
pt_expect n1, row(1) value("`exp_n1'") name(pt_model_desc:test4_n_analysis)
pt_expect m1, row(1) value("`exp_m1'") name(pt_model_desc:test4_missing)
pt_expect icc, row(1) value("") name(pt_model_desc:test4_icc_empty)
pt_expect est, row(1) value("") name(pt_model_desc:test4_est_empty)

*Test 5: a descriptive row fits the same table as a model row with the same options
use `one_time', clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(n0 n1 n2 m0 m1 m2 sum0 sum1 sum2 est p icc) using `results', replace
gen site = mod(pid, 8)
mixed y_cont i.arm || site:
pt_model y_cont, postname(`postname') treat(arm) type(cont) n_analysis(cols) missing(cols) icc
cap noisily pt_model y_cat, postname(`postname') treat(arm) type(cat) n_analysis(cols) missing(cols) icc descriptive
pt_record pt_model_desc:test5_fits_model_table, rc(`=_rc')
postclose `postname'

*Test 6: categorical: a label row, then one row per level with no. (%)
use `one_time', clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(measure n0 n1 n2 sum0 sum1 sum2 est p) using `results', replace
pt_model y_cat, postname(`postname') treat(arm) type(cat) n_analysis(cols) su_label(col) per descriptive
qui count if arm == `a3' & y_cat < .
local denom = r(N)
local exp_n2 = r(N)
qui count if arm == `a3' & y_cat == 2
local exp_mild = "`r(N)' (" + string(r(N) / `denom' * 100, "%12.1f") + "%)"
postclose `postname'
use `results', clear
pt_record pt_model_desc:test6_rows, rc(`=_N != 5')
pt_expect variable, row(1) value("Severity") name(pt_model_desc:test6_label_row)
pt_expect sum2, row(1) value("") name(pt_model_desc:test6_label_row_empty)
pt_expect variable, row(3) value("    Mild") name(pt_model_desc:test6_level_label)
pt_expect sum2, row(3) value("`exp_mild'") name(pt_model_desc:test6_level_count)
pt_expect n2, row(3) value("`exp_n2'") name(pt_model_desc:test6_level_n)
pt_expect measure, row(3) value("no. (%)") name(pt_model_desc:test6_su_label_col)
pt_expect est, row(3) value("") name(pt_model_desc:test6_est_empty)

*Test 7: categorical with su_label(append) and missing(brackets)
use `one_time', clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace
pt_model y_cat, postname(`postname') treat(arm) type(cat) su_label(append) missing(brackets) descriptive
qui count if arm == `a1' & y_cat == .
local exp_miss "[`r(N)']"
postclose `postname'
use `results', clear
pt_expect variable, row(1) value("Severity - no. (%) [missing]") name(pt_model_desc:test7_append)
local got = sum0[2]
pt_record pt_model_desc:test7_missing_brackets, rc(`=strpos("`got'", "`exp_miss'") == 0')

*Test 8: pt_model_mt, continuous: one row per timepoint, empty estimates
use `long_data', clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(n0 n1 n2 sum0 sum1 sum2 est p) using `results', replace
pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time) type(cont) n_analysis(cols) descriptive
qui su y_cont if arm == `a2' & time == `t2'
local exp_sum1 = string(r(mean), "%12.1f") + " (" + string(r(sd), "%12.1f") + ")"
local exp_n1 = r(N)
postclose `postname'
use `results', clear
pt_record pt_model_desc:test8_rows, rc(`=_N != 3')
pt_expect sum1, row(3) value("`exp_sum1'") name(pt_model_desc:test8_mean_time2)
pt_expect n1, row(3) value("`exp_n1'") name(pt_model_desc:test8_n_time2)
pt_expect est, row(3) value("") name(pt_model_desc:test8_est_empty)
pt_expect p, row(1) value("") name(pt_model_desc:test8_no_interaction_p)

*Test 9: pt_model_mt, categorical: a timepoint row, then one row per level
use `long_data', clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace
pt_model_mt y_cat, postname(`postname') treat(arm) time_var(time) type(cat) descriptive
qui count if arm == `a1' & time == `t2' & y_cat < .
local denom = r(N)
qui count if arm == `a1' & time == `t2' & y_cat == 4
local exp_severe = "`r(N)' (" + string(r(N) / `denom' * 100, "%12.1f") + ")"
local lab_t2 : label (time) `t2'
postclose `postname'
use `results', clear
pt_record pt_model_desc:test9_rows, rc(`=_N != 11')
pt_expect variable, row(7) value("    `lab_t2'  ") name(pt_model_desc:test9_timepoint_row)
pt_expect variable, row(11) value("        Severe") name(pt_model_desc:test9_level_label)
pt_expect sum0, row(11) value("`exp_severe'") name(pt_model_desc:test9_level_count_time2)

*Test 10: pt_model_mt: three arms, model and descriptive rows in one table, with icc
use `long_data', clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(n0 n1 n2 sum0 sum1 sum2 est p icc) using `results', replace
mixed y_cont i.arm##i.time || pid:
pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time) type(cont) n_analysis(cols) icc
cap noisily pt_model_mt y_cat, postname(`postname') treat(arm) time_var(time) type(cat) n_analysis(cols) icc descriptive
pt_record pt_model_desc:test10_mt_fits_model_table, rc(`=_rc')
cap noisily pt_model_mt y_bin, postname(`postname') treat(arm) time_var(time) type(bin) n_analysis(cols) icc descriptive
pt_record pt_model_desc:test10_mt_binary_fits, rc(`=_rc')
postclose `postname'

*Test 11: the outcome must be the last model's outcome (not in descriptive mode)
use `one_time', clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace
regress y_cont i.arm
pt_expect_error, name(pt_model_desc:test11_pt_model_mismatch): pt_model y_bin, postname(`postname') treat(arm)
cap noisily pt_model y_cont, postname(`postname') treat(arm)
pt_record pt_model_desc:test11_pt_model_match, rc(`=_rc')
postclose `postname'

use `long_data', clear
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace
mixed y_cont i.arm##i.time || pid:
pt_expect_error, name(pt_model_desc:test11_pt_model_mt_mismatch): pt_model_mt y_bin, postname(`postname') treat(arm) time_var(time)
postclose `postname'

*Test 12: nodepvarcheck allows a different outcome, e.g. summaries of y after a model of a transformed y
use `one_time', clear
gen y_rank = y_cont
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace
regress y_rank i.arm
cap noisily pt_model y_cont, postname(`postname') treat(arm) type(cont) nodepvarcheck
pt_record pt_model_desc:test12_pt_model_nodepvarcheck, rc(`=_rc')
postclose `postname'
use `long_data', clear
gen y_rank = y_cont
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace
mixed y_rank i.arm##i.time || pid:
cap noisily pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time) type(cont) nodepvarcheck
pt_record pt_model_desc:test12_pt_model_mt_nodepvarcheck, rc(`=_rc')
postclose `postname'

*Test 13: after stcox the outcome is _t: the stset time and failure variables are accepted
use `one_time', clear
keep if arm != `a3'
set seed 12
gen surv_time = rexponential(10)
gen surv_event = runiform() < 0.6
stset surv_time, failure(surv_event)
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum1 sum2 est p) using `results', replace
stcox i.arm
cap noisily pt_model surv_time, postname(`postname') treat(arm) type(skew)
pt_record pt_model_desc:test13_stcox_time_var, rc(`=_rc')
stcox i.arm
cap noisily pt_model surv_event, postname(`postname') treat(arm) type(bin)
pt_record pt_model_desc:test13_stcox_failure_var, rc(`=_rc')
stcox i.arm
pt_expect_error, name(pt_model_desc:test13_stcox_mismatch): pt_model y_cont, postname(`postname') treat(arm)
postclose `postname'
