*Unit test for pt_parse

use "$test_data", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$host_ado"


local test 0
di _newline(1) "Test `++test'"
pt_parse gender cont(age qol) ethnicity
sreturn list
assert "`s(section1))'" == "gender"
assert "`s(section2))'" == "age qol, type(cont)"
assert "`s(section3))'" == "ethnicity" 	
assert `s(n_sections))'  == 3	
