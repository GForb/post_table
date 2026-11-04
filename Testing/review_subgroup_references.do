/*
Manual review of the pt_subgroup reference tables added or changed by the joint
interaction test fix: table 7 (pt_subgroup test 3, regenerated) and table 10
(pt_subgroup test 5, new). All other tables are in review_new_references.do.

For each table this file lists the saved reference table, loads the input data
the test uses, runs the model and pauses so the table can be checked against the
data. in_analysis marks the observations the model used (e(sample)).

Run interactively from the repository root:
	cd "<path to post_table>"
	do Testing/review_subgroup_references.do
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
	di _n as result "{hline 100}" _n "TABLE `number': Testing/`reference'" _n "{hline 100}"
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
*  Table 7: pt_subgroup test 3
********************************************************************************
di as text "Made by: regress y_skew i.allocation##i.agegrp"
di as text "         pt_subgroup y_skew, sub_var(agegrp) treat(allocation) type(skew) su_label(append) use_outcome_label"
di as text "Check:   header p against the testparm output below. Only the header p has changed (was 0.23)."

review_table 7 pt_subgroup/pt_subgroup_test3_reference.dta

review_data "pt_subgroup/Input data/pt_subgroup_input.dta"
regress y_skew i.allocation##i.agegrp
gen in_analysis = e(sample)
testparm 1.allocation#i.agegrp
review_pause 7


********************************************************************************
*  Table 10: pt_subgroup test 5
********************************************************************************
di as text "Made by: regress y_cont i.arm##i.agegrp"
di as text "         pt_subgroup y_cont, sub_var(agegrp) treat(arm) type(cont)"
di as text "         pt_subgroup y_cont, sub_var(agegrp) treat(arm) type(cont) prim_treat(1)"
di as text "Check:   rows 1-4 are High dose vs Control, rows 5-8 are Low dose vs Control;"
di as text "         mean (sd) for all three arms in both blocks, where in_analysis==1;"
di as text "         estimates against the lincom output; header p against the testparm output for that arm"

review_table 10 pt_subgroup/pt_subgroup_test5_reference.dta

review_data "pt_subgroup/Input data/pt_subgroup_multiarm_input.dta"
regress y_cont i.arm##i.agegrp
gen in_analysis = e(sample)
tabstat y_cont if in_analysis, by(arm) stats(mean sd n) nototal
bysort agegrp: tabstat y_cont if in_analysis, by(arm) stats(mean sd n) nototal
foreach a in 2 1 {
	foreach k in 1 2 3 {
		lincom `a'.arm + `a'.arm#`k'.agegrp
	}
	testparm `a'.arm#i.agegrp
}
review_pause 10
