*Tests for the nosummary option of pt_model and pt_model_mt (and so pt_subgroup).
*Each table is posted twice from the same model: in full, and with nosummary to a postfile
*without the summary columns. Every shared cell must be the same. No reference tables.

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

cd "$pt_root/Testing/pt_model"

*compares the shared columns of two posted tables, row by row; diffs counts the differences
*(a different number of rows counts as one)
cap program drop nosum_compare
program define nosum_compare, rclass
	syntax , full(string) short(string) vars(string) [label_strip(string)]
	use `short', clear
	foreach v in `vars' {
		rename `v' s_`v'
	}
	gen long row = _n
	tempfile s
	save `s'
	use `full', clear
	gen long row = _n
	merge 1:1 row using `s'
	qui count if _merge != 3
	local diffs = r(N) > 0
	if `"`label_strip'"' != "" replace variable = subinstr(variable, `"`label_strip'"', "", 1)
	foreach v in `vars' {
		qui count if strtrim(`v') != strtrim(s_`v')
		local diffs = `diffs' + r(N)
	}
	qui count if s_est != ""
	return scalar n_est = r(N)
	return scalar diffs = `diffs'
end

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
tempname pf ps
tempfile full short
postfile `pf' str60 variable str20(measure n1 n2 sum1 sum2 est p) using `full', replace
postfile `ps' str60 variable str20(n1 n2 est p) using `short', replace
regress y_cont i.arm
pt_model y_cont, postname(`pf') treat(arm) type(cont) su_label(col) n_analysis(cols)
*two-arm pt_model reads r(table), so the model is refit before the second call
regress y_cont i.arm
cap noisily pt_model y_cont, postname(`ps') treat(arm) type(cont) su_label(col) n_analysis(cols) nosummary
pt_record pt_model_nosum:test1_runs, rc(`=_rc')
postclose `pf'
postclose `ps'
nosum_compare, full(`full') short(`short') vars(variable n1 n2 est p)
pt_record pt_model_nosum:test1_same_cells, rc(`r(diffs)')
pt_record pt_model_nosum:test1_has_estimate, rc(`=r(n_est) != 1')

*Test 2: pt_model, three arms, with gap(1): comparison rows keep their estimates
use `one_time', clear
regress y_cont i.arm
tempname pf ps
tempfile full short
postfile `pf' str60 variable str20(sum0 sum1 sum2 est p) using `full', replace
postfile `ps' str60 variable str20(est p) using `short', replace
pt_model y_cont, postname(`pf') treat(arm) type(cont) compare(1v0 2v0) gap(1)
cap noisily pt_model y_cont, postname(`ps') treat(arm) type(cont) compare(1v0 2v0) gap(1) nosummary
pt_record pt_model_nosum:test2_runs, rc(`=_rc')
postclose `pf'
postclose `ps'
nosum_compare, full(`full') short(`short') vars(variable est p)
pt_record pt_model_nosum:test2_same_cells, rc(`r(diffs)')
pt_record pt_model_nosum:test2_has_estimates, rc(`=r(n_est) != 2')

*Test 3: pt_model_mt, three arms, with su_label(append), n_analysis(cols), icc and gap(1)
use `long_data', clear
mixed y_cont i.arm##i.time || pid:
tempname pf ps
tempfile full short
postfile `pf' str60 variable str20(n0 n1 n2 sum0 sum1 sum2 est p icc) using `full', replace
postfile `ps' str60 variable str20(n0 n1 n2 est p icc) using `short', replace
pt_model_mt y_cont, postname(`pf') treat(arm) time_var(time) type(cont) su_label(append) n_analysis(cols) icc gap(1) compare(1v0 2v0)
cap noisily pt_model_mt y_cont, postname(`ps') treat(arm) time_var(time) type(cont) su_label(append) n_analysis(cols) icc gap(1) compare(1v0 2v0) nosummary
pt_record pt_model_nosum:test3_runs, rc(`=_rc')
postclose `pf'
postclose `ps'
*the label loses only the appended summary label
nosum_compare, full(`full') short(`short') vars(variable n0 n1 n2 est p icc) label_strip(" - mean (sd)")
pt_record pt_model_nosum:test3_same_cells, rc(`r(diffs)')
pt_record pt_model_nosum:test3_has_estimates, rc(`=r(n_est) == 0')

*Test 4: nosummary with descriptive stops
use `one_time', clear
keep if arm != `a3'
tempname postname
tempfile results
postfile `postname' str60 variable str20(est p) using `results', replace
pt_expect_error, name(pt_model_nosum:test4_pt_model_with_descriptive): pt_model y_cont, postname(`postname') treat(arm) type(cont) descriptive nosummary
pt_expect_error, name(pt_model_nosum:test4_pt_model_mt_with_descriptive): pt_model_mt y_cont, postname(`postname') treat(arm) time_var(time) type(cont) descriptive nosummary
postclose `postname'
