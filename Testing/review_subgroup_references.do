/*
Manual review of the reference tables added or changed by the joint interaction
test fix and the multi-arm comparisons: table 7 (pt_subgroup test 3), table 10
(pt_subgroup test 5), table 11 (pt_model test 5) and table 12 (pt_model_mt test 5).
All other tables are in review_new_references.do.

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
di as text "Check:   row 1 is the title; rows 2, 6 and 10 name the comparison and have its interaction p;"
di as text "         summaries for all three arms in rows 3-5 only, where in_analysis==1;"
di as text "         estimates against the lincom output; interaction p against the test output"

review_table 10 pt_subgroup/pt_subgroup_test5_reference.dta

review_data "pt_subgroup/Input data/pt_subgroup_multiarm_input.dta"
regress y_cont i.arm##i.agegrp
gen in_analysis = e(sample)
bysort agegrp: tabstat y_cont if in_analysis, by(arm) stats(mean sd n) nototal
foreach a in 1 2 {
	foreach k in 1 2 3 {
		lincom `a'.arm + `a'.arm#`k'.agegrp
	}
	testparm `a'.arm#i.agegrp
}
foreach k in 1 2 3 {
	lincom 2.arm + 2.arm#`k'.agegrp - 1.arm - 1.arm#`k'.agegrp
}
test (2.arm#2.agegrp = 1.arm#2.agegrp) (2.arm#3.agegrp = 1.arm#3.agegrp)
review_pause 10


********************************************************************************
*  Table 11: pt_model test 5
********************************************************************************
di as text "Made by: regress y_cont i.arm"
di as text "         pt_model y_cont, treat(arm) type(cont)"
di as text "Check:   row 1 has mean (sd) for each arm, where in_analysis==1, and no estimate;"
di as text "         rows 2-4 against the lincom output"

review_table 11 pt_model/pt_model_test5_reference.dta

review_data "pt_subgroup/Input data/pt_subgroup_multiarm_input.dta"
regress y_cont i.arm
gen in_analysis = e(sample)
tabstat y_cont if in_analysis, by(arm) stats(mean sd n) nototal
lincom 1.arm
lincom 2.arm
lincom 2.arm - 1.arm
review_pause 11


********************************************************************************
*  Table 12: pt_model_mt test 5
********************************************************************************
di as text "Made by: mixed y_cont i.arm##i.time || pid:"
di as text "         pt_model_mt y_cont, time_var(time) treat(arm) type(cont)"
di as text "Check:   row 1 is the title; rows 2, 5 and 8 name the comparison, with no p;"
di as text "         summaries in rows 3-4 only, where in_analysis==1;"
di as text "         estimates and p against the lincom output"

review_table 12 pt_model_mt/pt_model_mt_test5_reference.dta

review_data "pt_model_mt/Input data/pt_model_mt_multiarm_input.dta"
mixed y_cont i.arm##i.time || pid:
gen in_analysis = e(sample)
bysort time: tabstat y_cont if in_analysis, by(arm) stats(mean sd n) nototal
foreach a in 1 2 {
	foreach k in 1 2 {
		lincom `a'.arm + `a'.arm#`k'.time
	}
}
foreach k in 1 2 {
	lincom 2.arm + 2.arm#`k'.time - 1.arm - 1.arm#`k'.time
}
review_pause 12
