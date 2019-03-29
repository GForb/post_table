*Unit test for pt_su_mean_sd

global dir "N:\Automating reporting\Git repository\post_table"

use "N:\Automating reporting\Git repository\post_table\Examples\Data\eg_data2", clear

*Executing pt_regress

if "$master_set_ado" == "" do "$dir\pt_regress.ado"


*Tesging pt_su_mean_sd
local test = 0

di  _newline(1) "Test `++test'"
pt_su_mean_sd age // test 1
assert "`r(sum)'" == "44.8 (10.1)" 
di "`r(sum)'"

di  _newline(1) "Test `++test'"
pt_su_mean_sd age, over(treat) over_lvl(1) // test 2
assert "`r(sum)'" == "44.9 (10.1)" 
di "`r(sum)'"

di  _newline(1) "Test `++test'"
pt_su_mean_sd age, over(treat) over_lvl(0) su_decimal(3) brackets(" [Test]") // test 3
assert "`r(sum)'" == "44.593 (10.123) [Test]" 
di "`r(sum)'"


