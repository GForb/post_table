*Unit test for pt_parse_options

use "$test_data", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$host_ado"


local test 0
di _newline(1) "Test `++test'"
pt_parse_options (gender, gend_opt) cont(age qol, inneroption) ethnicity, opt1 opt2 opt3 opt4 opt5 opt6("some text")
sreturn list
assert `"`s(options)'"' == `" opt1 opt2 opt3 opt4 opt5 opt6("some text")"'
assert `"`s(anylist)'"' == "(gender, gend_opt) cont(age qol, inneroption) ethnicity"



