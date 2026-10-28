/*
Creates the simulated input datasets used by the newer tests. This is kept as a
record of how the data were made; the tests load the saved files and do not
run this. The files are saved without replace, so existing input data are never
overwritten. To recreate a file, delete it first.

Run from the repository root:
	do Testing/make_input_data.do
*/

if "$pt_root" == "" global pt_root "`c(pwd)'"


*pt_model tests 3 and 4: clustered by site, with missing outcome data
set seed 2024
clear
set obs 400
gen site = ceil(_n/20)
gen allocation = rbinomial(1, 0.5)
bysort site: gen u = rnormal(0, 1) if _n == 1
bysort site: replace u = u[1]
gen y_cont = 10 + allocation + u + rnormal(0, 3)
gen y_bin = y_cont > 11
gen y_null = rnormal(0, 1)
replace y_cont = . if runiform() < 0.1
replace y_bin = . if missing(y_cont)
label var y_cont "Continuous"
label var y_bin "Binary"
label var y_null "Null"
save "$pt_root/Testing/pt_model/Input data/pt_model_input.dta"


*pt_model_mt tests 2 and 3: same data as pt_model_mt test 1
set seed 100
clear
local n_obs  1000
set obs `n_obs'
gen pid = _n
gen allocation = rbinomial(1, 0.5)
expand 2
gen time = round(_n/`n_obs')
replace time = time + 1
sort pid time
gen y_cont_err = rnormal(0, 3)
gen y_cont = y_cont_err + allocation + time/3
gen y_bin = 0
replace y_bin = 1 if y_cont > 0
gen y_count = rpoisson(allocation + 2 + time/3)
label var y_cont "Test Continuous Outcome"
label var y_bin "Binary"
label var y_count "Poisson"
label define time 1 "Time 1" 2 "Time 2" 3 "Time 3"
label values time time
save "$pt_root/Testing/pt_model_mt/Input data/pt_model_mt_input.dta"


*pt_subgroup tests
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
save "$pt_root/Testing/pt_subgroup/Input data/pt_subgroup_input.dta"


*pt_base extra test: example data plus a categorical variable without value labels
use "$pt_root/Examples/Creating comprehensive examples/eg_data2", clear
clonevar ethnicity_nolab = ethnicity
label values ethnicity_nolab
label var ethnicity_nolab "Ethnicity (no value labels)"
save "$pt_root/Testing/pt_base/Input data/pt_base_extra_input.dta"
