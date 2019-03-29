*Unit test for pt_parse

use "$test_data", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$host_ado"




local test 0
di _newline(1) "Test `++test'"
pt_parse_anylist2 gender  ethnicity cont(age qol, subopt) 
sreturn list
assert "`s(section1))'" == "gender ethnicity"
assert "`s(section2))'" == "age qol, subopt"
assert `s(n_sections))'  == 2	
assert "`s(type1))'" == ""
assert "`s(type2))'" == "cont"


di _newline(1) "Test `++test'"
pt_parse_anylist2 gender cont(age qol, subopt) ethnicity
sreturn list
assert "`s(section1))'" == "gender"
assert "`s(section2))'" == `"age qol, subopt"'
assert "`s(section3))'" == "ethnicity" 	
assert `s(n_sections))'  == 3	
assert "`s(type1))'" == ""
assert "`s(type2))'" == "cont"
assert "`s(type3))'" == ""


di _newline(1) "Test `++test'"
pt_parse_anylist2 age gender ethnicity skew(qol bmi) bin(alcohol)
sreturn list
assert "`s(section1))'" == "age gender ethnicity"
assert "`s(section2))'" == `"qol bmi"'
assert "`s(section3))'" == "alcohol" 	
assert `s(n_sections))'  == 3	
assert "`s(type1))'" == ""
assert "`s(type2))'" == "skew"
assert "`s(type3))'" == "bin"


di _newline(1) "Test `++test'"
pt_parse_anylist2 gender cont(age qol, subopt("some text")) ethnicity
sreturn list
assert "`s(section1))'" == "gender"
assert "`s(section2))'" == `"age qol, subopt("some text")"'
assert "`s(section3))'" == "ethnicity" 	
assert `s(n_sections))'  == 3	
assert "`s(type1))'" == ""
assert "`s(type2))'" == "cont"
assert "`s(type3))'" == ""




di _newline(1) "Test `++test'"
pt_parse_anylist2 (gender) age ethnicity (age height weight) 
sreturn list
assert "`s(section1))'" == "gender"
assert "`s(section2))'" == `"age ethnicity"'
assert "`s(section3))'" == "age height weight" 	
assert `s(n_sections))'  == 3	
assert "`s(type1))'" == ""
assert "`s(type2))'" == ""
assert "`s(type3))'" == ""

