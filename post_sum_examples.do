cd "N:\Automating reporting\Example data and results"

*Baseline table not by group
use eg_data2, clear



*open postfile with four groups
tempname postname
postfile `postname'  str60 variable str20(sum1 sum2 sum3) using ps_eg1, replace
count
local N = r(N)
post `postname' ("Contnuous variables") ("N") ("mean (sd)") ("Range")
post_table_sum age bmi qol, postname(`postname') stats(N mean_sd range)
postclose `postname'
use ps_eg1, clear
