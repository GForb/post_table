/*
Manual review of the reference tables added in the more-tests branch.

For each table this file lists the saved reference table, then loads the saved
input data that the test uses (Testing/<command>/Input data/) and pauses so the
table can be checked against the data.

The model that produced the table is also run quietly, so that:
  - in_analysis (or in_<outcome> in table 2) marks the observations it used (e(sample))
  - typing the model name (e.g. regress, mixed) redisplays its estimates

Run interactively from the repository root:
	cd "<path to post_table>"
	do Testing/review_new_references.do
At each pause, check the table, then type q and press Enter to go to the next one.
*/

global pt_root "`c(pwd)'"
set linesize 200
pause on


*************Programs***************
cap prog drop review_table
prog define review_table
	* Lists a saved reference table
	args number reference
	di _n as result "{hline 100}" _n "TABLE `number' of 9: Testing/`reference'" _n "{hline 100}"
	use "$pt_root/Testing/`reference'", clear
	list, noobs sep(0) abbrev(16) table
end

cap prog drop review_data
prog define review_data
	* Loads the saved input data used by the test
	args input
	di _n as result "Input data: Testing/`input'"
	use "$pt_root/Testing/`input'", clear
	describe, short
end

cap prog drop review_pause
prog define review_pause
	* Pauses for checking (skipped in batch mode, where pause would wait for input)
	args number
	if "`c(mode)'" == "batch" exit
	pause Table `number': check the table above against the data in memory. Type q to continue.
end


********************************************************************************
*  Table 1: pt_model test 3
********************************************************************************
review_table 1 pt_model/pt_model_test3_reference.dta
di as text "Made by: mixed y_cont allocation || site:"
di as text "         pt_model y_cont, treat(allocation) missing(cols) icc per decimal(2)"
di as text "Check:   missing n (%) per group (% of everyone in the group); mean (sd) of y_cont where in_analysis==1;"
di as text "         estimate/CI/p against the mixed output; icc against estat icc; 2 dp throughout"

review_data "pt_model/Input data/pt_model_input.dta"
qui mixed y_cont allocation || site:
gen in_analysis = e(sample)
review_pause 1


********************************************************************************
*  Table 2: pt_model test 4
********************************************************************************
review_table 2 pt_model/pt_model_test4_reference.dta
di as text "Made by (three rows, plus a gap row after the first):"
di as text `"  regress y_null allocation; pt_model y_null, treat(allocation) gap(1) var_lab("Null outcome") su_label(append)"'
di as text "  logit y_bin allocation;    pt_model y_bin, treat(allocation) treat_grps(1 0) exp per positive(0) su_decimal(2) est_decimal(3)"
di as text "  regress y_cont allocation; pt_model y_cont, treat(allocation) missing(brackets)"
di as text "Check:   -0.0 in row 1; binary row counts y_bin==0, with allocation 1 in the first column;"
di as text "         [n] in row 4 is the number missing y_cont in each group"
di as text "         The models are run in order, so only the last (regress y_cont) can be redisplayed."

review_data "pt_model/Input data/pt_model_input.dta"
qui regress y_null allocation
gen in_null = e(sample)
qui logit y_bin allocation
gen in_bin = e(sample)
qui regress y_cont allocation
gen in_cont = e(sample)
review_pause 2


********************************************************************************
*  Table 3: pt_model_mt test 2
********************************************************************************
review_table 3 pt_model_mt/pt_model_mt_test2_reference.dta
di as text "Made by: melogit y_bin i.allocation##i.time || pid:"
di as text "         pt_model_mt y_bin, time_var(time) treat(allocation) exp timepoints(3 2 1)"
di as text "Check:   rows in order Time 3, 2, 1; n (%) of y_bin==1 by allocation and time;"
di as text "         odds ratios: lincom 1.allocation + 1.allocation#<t>.time, eform (Time 1 is the base level)"

review_data "pt_model_mt/Input data/pt_model_mt_input.dta"
qui melogit y_bin i.allocation##i.time || pid:
gen in_analysis = e(sample)
review_pause 3


********************************************************************************
*  Table 4: pt_model_mt test 3
********************************************************************************
review_table 4 pt_model_mt/pt_model_mt_test3_reference.dta
di as text "Made by: mixed y_count i.allocation##i.time || pid:"
di as text `"         pt_model_mt y_count, time_var(time) treat(allocation) type(skew) su_label(append) var_lab("Count (skewed)") gap(1) est_decimal(2)"'
di as text "Check:   median (IQR) of y_count by allocation and time; estimates to 2 dp from"
di as text "         lincom 1.allocation + 1.allocation#<t>.time; gap row at the end"

review_data "pt_model_mt/Input data/pt_model_mt_input.dta"
qui mixed y_count i.allocation##i.time || pid:
gen in_analysis = e(sample)
review_pause 4


********************************************************************************
*  Table 5: pt_subgroup test 1
********************************************************************************
review_table 5 pt_subgroup/pt_subgroup_test1_reference.dta
di as text "Made by: regress y_cont i.allocation##i.sex"
di as text "         pt_subgroup y_cont, sub_var(sex) treat(allocation) n_analysis(cols) su_label(col) gap(1)"
di as text "Check:   n and mean (sd) by allocation and sex where in_analysis==1;"
di as text "         Male estimate = lincom 1.allocation; Female = lincom 1.allocation + 1.allocation#2.sex;"
di as text "         header p = p-value of the interaction term; gap row at the end"

review_data "pt_subgroup/Input data/pt_subgroup_input.dta"
qui regress y_cont i.allocation##i.sex
gen in_analysis = e(sample)
review_pause 5


********************************************************************************
*  Table 6: pt_subgroup test 2
********************************************************************************
review_table 6 pt_subgroup/pt_subgroup_test2_reference.dta
di as text "Made by: logit y_bin i.allocation##i.sex"
di as text `"         pt_subgroup y_bin, sub_var(sex) treat(allocation) treat_grps(1 0) exp est_decimal(2) var_lab("Sex (binary outcome)")"'
di as text "Check:   treated group in the first column; n (%) of y_bin==1 by allocation and sex;"
di as text "         odds ratios to 2 dp from lincom ..., eform; header p = p-value of the interaction term"

review_data "pt_subgroup/Input data/pt_subgroup_input.dta"
qui logit y_bin i.allocation##i.sex
gen in_analysis = e(sample)
review_pause 6


********************************************************************************
*  Table 7: pt_subgroup test 3
********************************************************************************
review_table 7 pt_subgroup/pt_subgroup_test3_reference.dta
di as text "Made by: regress y_skew i.allocation##i.agegrp"
di as text "         pt_subgroup y_skew, sub_var(agegrp) treat(allocation) type(skew) su_label(append) use_outcome_label prim_sub_grp(2)"
di as text "Check:   median (IQR) of y_skew by allocation and agegrp; estimates from lincom for each age group;"
di as text "         DESIGN QUESTION: the header p tests only 1.allocation#2.agegrp (40-59 vs 18-39),"
di as text "         not the joint interaction (compare: testparm 1.allocation#i.agegrp)"

review_data "pt_subgroup/Input data/pt_subgroup_input.dta"
qui regress y_skew i.allocation##i.agegrp
gen in_analysis = e(sample)
review_pause 7


********************************************************************************
*  Table 8: pt_subgroup test 4
********************************************************************************
review_table 8 pt_subgroup/pt_subgroup_test4_reference.dta
di as text "Made by: regress y_cont i.allocation##i.sex"
di as text "         pt_subgroup y_cont, sub_var(sex) treat(allocation) int_test_false sub_grps(2 1)"
di as text "Check:   Female row first; a p-value on each subgroup row (from its lincom); no header p-value"

review_data "pt_subgroup/Input data/pt_subgroup_input.dta"
qui regress y_cont i.allocation##i.sex
gen in_analysis = e(sample)
review_pause 8


********************************************************************************
*  Table 9: pt_base extra test 1
********************************************************************************
review_table 9 pt_base/pt_base_extra_test1_reference.dta
di as text "Made by: pt_base ethnicity ethnicity_nolab, over(treat) over_grps(1 0) type(cat) n_analysis(cols) order(group_over) su_label(col)"
di as text "Check:   n (%) per category by treat (tab ethnicity treat, col); denominators 454 / 435"
di as text "         (non-missing ethnicity in each group); is repeating the denominator on every row intended?;"
di as text "         ethnicity_nolab rows labelled with raw codes 0-4"

review_data "pt_base/Input data/pt_base_extra_input.dta"
review_pause 9

di _n as result "Review complete."
