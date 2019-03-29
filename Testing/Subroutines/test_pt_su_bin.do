*Unit test for pt_su_n_per

global dir "N:\Automating reporting\Git repository\post_table"

use "N:\Automating reporting\Git repository\post_table\Examples\Data\eg_data2", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$dir\pt_regress.ado"


*Tesging pt_su_n_per
local test = 0 

di  _newline(1) "Test `++test'"
pt_su_bin gender // test 1
if "`r(sum)'" != "519 (51.9)" local fail`test' = 1

di  _newline(1) "Test `++test'"
pt_su_bin gender, over(treat) over_lvl(1) count_only // test 2
if "`r(sum)'" != "258" local fail`test' = 1
di "`r(sum)'"

di  _newline(1) "Test `++test'"
pt_su_bin gender, over(treat) over_lvl(0) su_decimal(3) brackets(" [Test]") positive(0) per // test 3
if "`r(sum)'" != "233 (47.166%) [Test]" local fail`test' = 1
di "`r(sum)'"



forvalues i = 1 (1) `test' {
	if "`fail`i''" != "" di as error "Test `i' failed"
	else di as result "Test `i' paseed"
}
