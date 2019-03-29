*Unit test for pt_su_n_per

use "$test_data", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$host_ado"

*Tesging pt_su_n_per
local test = 0 

di  _newline(1) "Test `++test'"
pt_su_bin gender // test 1
assert "`r(sum)'" == "519 (51.9)" 

di  _newline(1) "Test `++test'"
pt_su_bin gender, over(treat) over_lvl(1) count_only // test 2
assert "`r(sum)'" == "258" // 
di "`r(sum)'"

di  _newline(1) "Test `++test'"
pt_su_bin gender, over(treat) over_lvl(0) su_decimal(3) brackets(" [Test]") positive(0) per // test 3
assert "`r(sum)'" == "233 (47.166%) [Test]" 
di "`r(sum)'"

di  _newline(1) "Test `++test'"
pt_su_bin ethnicity, over(treat) over_lvl(0) su_decimal(3) brackets(" [Test]") positive(3) per // test 3
assert "`r(sum)'" == "103 (23.678%) [Test]" 
di "`r(sum)'"

di  _newline(1) "Test `++test'"
pt_su_bin ethnicity, over(treat) over_lvl(0) su_decimal(3) brackets(" [Test]") positive(5) per // test 3
assert "`r(sum)'" == "0 (0.000%) [Test]" 
