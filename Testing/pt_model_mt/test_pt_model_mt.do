*Generate data

cd "/Users/k1811974/Library/CloudStorage/OneDrive-King'sCollegeLondon/Programming/Automating reporting/Git repository/post_table/Testing/pt_model_mt"

*prog drop _all
*do "../../pt_subgroup.ado"
*do "../../pt_model_mt.ado"

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

tempfile test_data

label define time 1 "Time 1" 2 "Time 2" 3 "Time 3"
label values time time
save `test_data'

tempname postname
tempfile results
postfile `postname'  str60 variable str20(n1 n2 sum1 sum2 est p) using `results' , replace 

post `postname' ("Variable") ("N1") ("N2") ("summary group 1")  ("summary group 2") ("est and CI") ("p-value")  

mixed y_cont  i.allocation##i.time || pid:

pt_model_mt y_cont, postname(`postname') time_var(time) treat(allocation) decimal(2) n_analysis(cols) 

levelsof time, local(time_values)
local first = 1
foreach t in `time_values' {
if `first' {
		lincom 1.allocation
	}
	else {
		lincom 1.allocation + 1.allocation#`t'.time - 0.allocation#`t'.time
	}
	local first = 0
}




postclose `postname'

use `results', clear

cf _all using "Test Data/pt_model_mt_test_data.dta", all
