*Unit test for pt_su_mean_sd

global dir "N:\Automating reporting\Git repository\post_table"

use "N:\Automating reporting\Git repository\post_table\Examples\Data\eg_data2", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$dir\pt_regress.ado"


*Tesging pt_su_median_iqr
*syntax varlist(numeric max = 1), [over(string) over_lvl(integer -999999) su_decimal(integer 1) brackets(string)]



local test 0
di _newline(1) "Test `++test'"
pt_su_median_iqr age // test 1
di "`r(sum)'"
assert "`r(sum)'" == "44.6 (37.7-51.5)" 

di  _newline(1) "Test `++test'"
pt_su_median_iqr age, over(treat) over_lvl(1)  // test 2
di "`r(sum)'"
assert "`r(sum)'" == "45.0 (37.5-51.5)" 

di  _newline(1) "Test `++test'"
pt_su_median_iqr age, over(treat) over_lvl(0) su_decimal(3) brackets(" [Test]") // test 3
di "`r(sum)'"
assert "`r(sum)'" == "44.109 (37.985-51.394) [Test]" 
