*Tests for the countcolumns option of every post_table command (pt_count_columns.ado).
*Each case asks for the column count, opens a postfile with exactly that many columns and
*runs the same command on real data: it only completes if every row has that many columns.

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

*cc_check: countcolumns, then post to a postfile of r(n_cols) columns.
*countcolumns replaces r(), so refit() refits the model before the real call.
cap program drop cc_check
program define cc_check
	_on_colon_parse `0'
	local cmd `"`s(after)'"'
	local 0 `"`s(before)'"'
	syntax , name(string) [refit(string) expect(integer -1)]
	*countcolumns needs no postfile: the name given is never opened
	cap noisily `cmd' postname(not_open) countcolumns
	local rc = _rc
	pt_record `name'_count_runs, rc(`rc')
	if `rc' exit
	local n = r(n_cols)
	if `expect' >= 0 pt_record `name'_count_is_`expect', rc(`=`n' != `expect'')
	local vars ""
	forvalues c = 1/`n' {
		local vars `vars' c`c'
	}
	tempname pf
	tempfile res
	postfile `pf' str80(`vars') using `res', replace
	if `"`refit'"' != "" qui `refit'
	cap noisily `cmd' postname(`pf')
	local rc = _rc
	postclose `pf'
	pt_record `name'_posts_`n'_columns, rc(`rc')
end

use "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear
set seed 2811
gen y_cat = runiformint(1, 4)
gen y_bin = y_cont > 11 if y_cont < .
qui levelsof arm, local(arms)
local a3 : word 3 of `arms'
qui levelsof time, local(times)
local t1 : word 1 of `times'
tempfile long_data
save `long_data'
keep if time == `t1'
tempfile one_time
save `one_time'

*pt_model, two arms, every optional column
use `one_time', clear
keep if arm != `a3'
gen site = mod(pid, 8)
mixed y_cont i.arm || site:
cc_check, name(cc:pt_model_2arm) expect(11) refit(mixed y_cont i.arm || site:): ///
	pt_model y_cont, treat(arm) treat_grps(0 1) type(cont) su_label(col) n_analysis(cols) missing(cols) icc

*pt_model, three arms, with gap
use `one_time', clear
regress y_cont i.arm
cc_check, name(cc:pt_model_3arm) refit(regress y_cont i.arm): ///
	pt_model y_cont, treat(arm) treat_grps(`arms') type(cont) compare(1v0 2v0) gap(1) n_analysis(cols)

*pt_model, nosummary
use `one_time', clear
regress y_cont i.arm
cc_check, name(cc:pt_model_nosummary) expect(6) refit(regress y_cont i.arm): ///
	pt_model y_cont, treat(arm) treat_grps(`arms') type(cont) compare(1v0 2v0) nosummary su_label(col) n_analysis(cols)

*pt_model, descriptive categorical
use `one_time', clear
cc_check, name(cc:pt_model_desc_cat): ///
	pt_model y_cat, treat(arm) treat_grps(`arms') type(cat) descriptive compare(1v0 2v0) su_label(col) missing(cols)

*pt_model_mt, three arms, with icc and n_analysis(cols)
use `long_data', clear
mixed y_cont i.arm##i.time || pid:
cc_check, name(cc:pt_model_mt) refit(mixed y_cont i.arm##i.time || pid:): ///
	pt_model_mt y_cont, treat(arm) treat_grps(`arms') time_var(time) type(cont) n_analysis(cols) icc su_label(col) gap(1) compare(1v0 2v0)

*pt_subgroup, three arms, subgroup = time
use `long_data', clear
mixed y_cont i.arm##i.time || pid:
cc_check, name(cc:pt_subgroup) refit(mixed y_cont i.arm##i.time || pid:): ///
	pt_subgroup y_cont, treat(arm) treat_grps(`arms') sub_var(time) type(cont) missing(cols) compare(1v0 2v0)

*pt_base, over with an overall column, every optional column, cont, bin and cat rows
use `one_time', clear
cc_check, name(cc:pt_base_all) expect(16): ///
	pt_base y_cont y_bin y_cat, over(arm) over_grps(`arms') overall(last) n_analysis(cols %) missing(cols) su_label(col) cat_col comment(note) gap(1)

*pt_base, order(group_over) with sum_cols_first, n_analysis and missing columns
use `one_time', clear
cc_check, name(cc:pt_base_group_over): ///
	pt_base y_cont y_cat, over(arm) over_grps(`arms') order(group_over) sum_cols_first n_analysis(cols) missing(cols)

*pt_base, no over
use `one_time', clear
cc_check, name(cc:pt_base_no_over) expect(3): ///
	pt_base y_cont y_cat, missing(cols) gap_end(1)

*pt_sum, over with overall first and a comment; then order(group_sum)
use `one_time', clear
cc_check, name(cc:pt_sum_group_over) expect(10): ///
	pt_sum y_cont, stats(N mean_sd) over(arm) over_grps(`arms') overall(first) comment(note)
use `one_time', clear
cc_check, name(cc:pt_sum_group_sum) expect(7): ///
	pt_sum y_cont, stats(N mean_sd) over(arm) over_grps(`arms') order(group_sum)

*No data in memory and variables that don't exist: the formula and column list
clear
cap noisily pt_model not_a_var, postname(p) treat(no_arm) n_analysis(cols) icc countcolumns
pt_record cc:no_data_runs, rc(`=_rc')
pt_record cc:no_data_formula, rc(`=r(formula) != "2 x k + 4"')
pt_record cc:no_data_no_n_cols, rc(`=r(n_cols) < .')
cap noisily pt_model_mt not_a_var, postname(p) time_var(no_time) treat_grps(1 2 3) countcolumns
pt_record cc:no_data_mt_n_cols, rc(`=r(n_cols) != 6')
cap noisily pt_base a b, postname(p) over(no_over) overall(first) countcolumns
pt_record cc:no_data_base_formula, rc(`=r(formula) != "1 x k + 2"')
