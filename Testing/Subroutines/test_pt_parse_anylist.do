*Unit test for pt_parse

use "$test_data", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$host_ado"




local test 0
di _newline(1) "Test `++test'"
pt_parse_anylist gender cont(age qol, subopt) ethnicity
sreturn list
assert "`s(section1))'" == "gender"
assert "`s(section2))'" == "age qol, subopt"
assert "`s(section3))'" == "ethnicity" 	
assert `s(n_sections))'  == 3	
assert "`s(type1))'" == ""
assert "`s(type2))'" == "cont"
assert "`s(type3))'" == ""



local test 0
di _newline(1) "Test `++test'"
pt_parse_anylist gender cont(age qol, subopt("some text")) ethnicity
sreturn list
assert "`s(section1))'" == "gender"
assert "`s(section2))'" == `"age qol, subopt("some text")"'
assert "`s(section3))'" == "ethnicity" 	
assert `s(n_sections))'  == 3	
assert "`s(type1))'" == ""
assert "`s(type2))'" == "cont"
assert "`s(type3))'" == ""
