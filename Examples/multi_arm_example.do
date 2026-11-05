/*
Reporting a trial with three arms. Each command posts one summary column per arm
and one estimate for each comparison. By default every pair of arms is compared,
higher value vs lower value. compare() chooses the comparisons: 2v0 is arm 2 minus arm 0.

Run from the repository root.
*/

use "Testing/pt_subgroup/Input data/pt_subgroup_multiarm_input.dta", clear

tempname postname
tempfile results
postfile `postname' str60 variable str20(control low high est p) using `results', replace

*Overall results, one row per comparison
regress y_cont i.arm
pt_model y_cont, postname(`postname') treat(arm) type(cont) gap(1)

*Comparisons with control only
pt_model y_cont, postname(`postname') treat(arm) type(cont) compare(1v0 2v0) gap(1)

*Subgroup results, one block of rows per comparison
regress y_cont i.arm##i.agegrp
pt_subgroup y_cont, postname(`postname') sub_var(agegrp) treat(arm) type(cont) compare(1v0 2v0)

postclose `postname'
use `results', clear
list, noobs sep(0) abbrev(16)


*Results at several timepoints work in the same way, after a treatment by time interaction:
use "Testing/pt_model_mt/Input data/pt_model_mt_multiarm_input.dta", clear

tempname postname
tempfile results
postfile `postname' str60 variable str20(control low high est p) using `results', replace

mixed y_cont i.arm##i.time || pid:
pt_model_mt y_cont, postname(`postname') time_var(time) treat(arm) type(cont) compare(1v0 2v0)

postclose `postname'
use `results', clear
list, noobs sep(0) abbrev(16)
