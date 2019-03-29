*Unit test for pt_pick_type

global dir "N:\Automating reporting\Git repository\post_table"

use "N:\Automating reporting\Git repository\post_table\Examples\Data\eg_data2", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$dir\pt_regress.ado"

local test 0
di _newline(1) "Test `++test'"
pt_pick_type age 
di "`r(type)'"
assert "`r(type)'" == "cont" 

di _newline(1) "Test `++test'"
pt_pick_type ethnicity 
di "`r(type)'"
assert "`r(type)'" == "cat" 

di _newline(1) "Test `++test'"
pt_pick_type smoking 
di "`r(type)'"
assert "`r(type)'" == "bin" 

