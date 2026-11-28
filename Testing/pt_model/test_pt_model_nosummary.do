*Tests for the nosummary option of pt_model and pt_model_mt (and so pt_subgroup).
*Each table is posted twice from the same model, with and without nosummary: the summary
*cells must be empty with it, and every other cell the same. No reference tables.

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

cd "$pt_root/Testing/pt_model"

use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
qui levelsof arm, local(arms)
local a3 : word 3 of `arms'
qui levelsof time, local(times)
local t1 : word 1 of `times'
tempfile long_data
save `long_data'
keep if time == `t1'
tempfile one_time
save `one_time'

*Test 1: pt_model, two arms, with su_label(col) and n_analysis(cols)
use `one_time', clear
keep if arm != `a3'
regress y_cont i.arm
tempname postname
tempfile results
postfile `postname' str60 variable str20(measure n1 n2 sum1 sum2 est p) using `results', replace
pt_model y_cont, postname(`postname') treat(arm) type(cont) su_label(col) n_analysis(cols)
*two-arm pt_model reads r(table), so the model is refit before the second call
regress y_cont i.arm
cap noisily pt_model y_cont, postname(`postname') treat(arm) type(cont) su_label(col) n_analysis(cols) nosummary
pt_record pt_model_nosum:test1_runs, rc(`=_rc')
postclose `postname'
use `results', clear
pt_record pt_model_nosum:test1_two_rows, rc(`=_N != 2')
foreach v in measure sum1 sum2 {
	pt_expect `v', row(2) value("") name(pt_model_nosum:test1_`v'_empty)
}
foreach v in variable n1 n2 est p {
	pt_record pt_model_nosum:test1_`v'_same, rc(`=`v'[1] != `v'[2]')
}
pt_record pt_model_nosum:test1_est_not_empty, rc(`=est[2] == ""')

*Test 2: pt_model, three arms: comparison rows keep their estimates, summaries empty
use `one_time', clear
regress y_cont i.arm
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p) using `results', replace
pt_model y_cont, postname(`postname') treat(arm) type(cont) compare(1v0 2v0)
pt_model y_cont, postname(`postname') treat(arm) type(cont) compare(1v0 2v0) nosummary
postclose `postname'
use `results', clear
pt_record pt_model_nosum:test2_six_rows, rc(`=_N != 6')
forvalues r = 4/6 {
	foreach v in sum0 sum1 sum2 {
		pt_expect `v', row(`r') value("") name(pt_model_nosum:test2_row`r'_`v'_empty)
	}
	foreach v in variable est p {
		pt_record pt_model_nosum:test2_row`r'_`v'_same, rc(`=`v'[`r'] != `v'[`r' - 3]')
	}
}

*Test 3: pt_model_mt, three arms, with su_label(append) and icc
use `long_data', clear
mixed y_cont i.arm##i.time || pid:
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum0 sum1 sum2 est p icc) using `results', replace
pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time) type(cont) su_label(append) icc compare(1v0 2v0)
cap noisily pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time) type(cont) su_label(append) icc compare(1v0 2v0) nosummary
pt_record pt_model_nosum:test3_runs, rc(`=_rc')
postclose `postname'
use `results', clear
local half = _N / 2
pt_record pt_model_nosum:test3_even_rows, rc(`=mod(_N, 2) != 0 | _N == 0')
local summaries_left = 0
local diffs = 0
forvalues r = 1/`half' {
	local r2 = `r' + `half'
	foreach v in sum0 sum1 sum2 {
		if `v'[`r2'] != "" local summaries_left = `summaries_left' + 1
	}
	foreach v in est p icc {
		if `v'[`r'] != `v'[`r2'] local diffs = `diffs' + 1
	}
	*the label loses only the appended summary label
	if strtrim(subinstr(variable[`r'], " - mean (sd)", "", 1)) != strtrim(variable[`r2']) local diffs = `diffs' + 1
}
pt_record pt_model_nosum:test3_summaries_empty, rc(`summaries_left')
pt_record pt_model_nosum:test3_other_cells_same, rc(`diffs')
qui count if est != "" in `=`half' + 1'/l
pt_record pt_model_nosum:test3_has_estimates, rc(`=r(N) == 0')

*Test 4: nosummary with descriptive stops
use `one_time', clear
keep if arm != `a3'
tempname postname
tempfile results
postfile `postname' str60 variable str20(sum1 sum2 est p) using `results', replace
pt_expect_error, name(pt_model_nosum:test4_pt_model_with_descriptive): pt_model y_cont, postname(`postname') treat(arm) type(cont) descriptive nosummary
pt_expect_error, name(pt_model_nosum:test4_pt_model_mt_with_descriptive): pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time) type(cont) descriptive nosummary
postclose `postname'
