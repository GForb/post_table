*Unit test for pt_pick_type

use "Examples\Data\eg_data2", clear

*Executing pt_regress
*if "$master_set_ado" == "" do "$dir\pt_regress.ado"

local test 0
di _newline(1) "Test `++test'"
pt_pick_type age 
di "`s(type)'"
assert "`s(type)'" == "cont" 

di _newline(1) "Test `++test'"
pt_pick_type ethnicity 
di "`s(type)'"
assert "`s(type)'" == "cat" 

di _newline(1) "Test `++test'"
pt_pick_type smoking 
di "`s(type)'"
assert "`s(type)'" == "bin" 

