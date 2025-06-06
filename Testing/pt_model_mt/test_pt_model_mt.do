*Generate data

cd "/Users/k1811974/Library/CloudStorage/OneDrive-King'sCollegeLondon/Programming/Automating reporting/Git repository/post_table/Testing/pt_model_mt"

set seed 100
clear
local n_obs  10000
set obs `n_obs'

gen pid = _n
gen allocation = rbinomial(1, 0.5)

expand 2


gen time = round(_n/n_obs)
replace time = time + 1
sort pid time

gen y_cont_err = rnormal(0, 3)
gen y_cont = y_cont_err + allocation + time/3

gen y_bin = 0
replace y_bin = 1 if y_cont > 0

gen y_count = rpoisson(allocation + 2 + time/3)

label var y_cont "Continuous"
label var y_bin "Binary"
label var y_count "Poisson"

tempfile test_data

label define time 1 "t1" 2 "t2" 3 "t3"
label values time time
save `test_data'

tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p) using `results' , replace 

post `postname' ("Variable") ("summary group 1")  ("summary group 2") ("est and CI") ("p-value")  

mixed y_cont  i.allocation##i.time || pid:
post_subgroup_beta y_cont, postname(`postname') sub_var(time) treat(allocation) decimal(2)
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
