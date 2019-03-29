*Unit test for pt_format_p

use "$test_data", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$host_ado"


local test 0
di _newline(1) "Test `++test'"
pt_format_p 0.99 
di "`r(p)'"
assert "`r( p)'" == "0.99" 

di _newline(1) "Test `++test'"
pt_format_p 0.9999999999999 
di "`r(p)'"
assert "`r( p)'" == "1.00" 

di _newline(1) "Test `++test'"
pt_format_p 0.0456 
di "`r(p)'"
assert "`r( p)'" == "0.046" 

di _newline(1) "Test `++test'"
pt_format_p 0.0697855874
di "`r(p)'"
assert "`r( p)'" == "0.070" 



di _newline(1) "Test `++test'"
pt_format_p 0.003565465
di "`r(p)'"
assert "`r( p)'" == "0.004" 


di _newline(1) "Test `++test'"
pt_format_p 0.001000001 
di "`r(p)'"
assert "`r( p)'" == "0.001" 

di _newline(1) "Test `++test'"
pt_format_p 0.0001000001 
di "`r(p)'"
assert "`r( p)'" == "0.0001" 

di _newline(1) "Test `++test'"
pt_format_p 0.00001000001 
di "`r(p)'"
assert "`r( p)'" == "<0.0001" 
