*Unit test for pt_parse

use "$test_data", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$host_ado"


local test 0
di _newline(1) "Test `++test'"
pt-base_parse cont(age)
di "`s(parsed)'"
assert "`r(age, type(cont))'" == "age, type(cont" 
