*Unit test for pt_parse

use "$test_data", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$host_ado"

local test = 0
di _newline(1) "Test `++test'"
pt_base2 age
return list
assert `"`r(pt_base1)'"' == "age  ,  "

di _newline(1) "Test `++test'"
pt_base2 age gender ethnicity skew(qol bmi) if ethnicity ==4, post(postname) over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col  n_analysis(append) 
return list
assert `"`r(pt_base1)'"' == "age gender ethnicity if ethnicity ==4 , post(postname) over(treat) overall(last) over_grps(1, 0) su_label(append) cat_col n_analysis(append) type(cont)"
assert `"`r(pt_base2)'"' == "qol bmi if ethnicity ==4 , post(postname) over(treat) overall(last) over_grps(1, 0) su_label(append) cat_col n_analysis(append) type(skew)"
assert `"`r(pt_base3)'"' == ""

di _newline(1) "Test `++test'"
pt_base2 age gender ethnicity skew(qol bmi) bin(alcohol), post(postname) over(treat)  overall(last)  over_grps(1, 0)  su_label(append)   missing(append)  comment("QoL measured using SF-36 global")
return list
assert `"`r(pt_base1)'"' == `"age gender ethnicity  , post(postname) over(treat) overall(last) over_grps(1, 0) su_label(append) missing(append) comment("QoL measured using SF-36 global") "'
assert `"`r(pt_base2)'"' == `"qol bmi  , post(postname) over(treat) overall(last) over_grps(1, 0) su_label(append) missing(append) comment("QoL measured using SF-36 global") type(skew)"'
assert `"`r(pt_base3)'"' == `"alcohol  , post(postname) over(treat) overall(last) over_grps(1, 0) su_label(append) missing(append) comment("QoL measured using SF-36 global") type(bin)"'




