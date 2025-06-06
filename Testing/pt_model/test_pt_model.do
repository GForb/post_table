*Generate data

cd "/Users/k1811974/Library/CloudStorage/OneDrive-King'sCollegeLondon/Programming/Automating reporting/Git repository/post_table/Testing/pt_model"

set seed 100
clear
set obs 300

gen allocation = rbinomial(1, 0.5)

gen y_cont_err = rnormal(0, 3)
gen y_cont = y_cont_err + allocation

gen y_bin = 0
replace y_bin = 1 if y_cont > 0

gen y_count = rpoisson(allocation + 2)

label var y_cont "Continuous"
label var y_bin "Binary"
label var y_count "Poisson"

tempfile test_data
save `test_data'

tempname postname
tempfile results
postfile `postname'  str60 variable str20(sum1 sum2 est p) using `results' , replace 

post `postname' ("Variable") ("summary group 1")  ("summary group 2") ("est and CI") ("p-value")  

regress y_cont allocation
pt_model y_cont, postname(`postname') treat(allocation) su_label(append)

logit y_bin allocation
pt_model y_bin, postname(`postname') treat(allocation) exp su_label(append)

poisson y_count allocation
pt_model y_count, postname(`postname') treat(allocation) exp  su_label(append)  

poisson y_count allocation, irr

pt_model y_count, postname(`postname') treat(allocation) exp type(skew) su_label(append)


postclose `postname'

use `results', clear
tempname test1
save `test1', replace
*save pt_model_test1_reference, replace // updates reference data

*With n-analysis cols

use `test_data', clear

tempname postname
tempfile results
postfile `postname'  str60 variable str20(n1 sum1 n2 sum2 est p) using `results' , replace 

post `postname' ("Variable") ("N group 1")  ("N group 2")  ("summary group 1")   ("summary group 2") ("est and CI") ("p-value")  

regress y_cont allocation
pt_model y_cont, postname(`postname') treat(allocation) su_label(append) n_analysis(cols)

logistic y_bin allocation
pt_model y_bin, postname(`postname') treat(allocation)  su_label(append)  n_analysis(cols)


poisson y_count allocation, irr

pt_model y_count, postname(`postname') treat(allocation)  type(skew) su_label(append)  n_analysis(cols)


postclose `postname'

use `results', clear
tempname test2
save `test2', replace
*save pt_model_test2_reference, replace // updates reference data

forvalues i = 1(1)2 {
	use `test`i'', clear
	cap noisily  cf _all using "pt_model_test`i'_reference", verbose
	local errors = r(Nsum)
	if `errors' == 0 di as result "Test `i' passed"
	if `errors' > 0 di as error "Test `i' failed" 
	
}

