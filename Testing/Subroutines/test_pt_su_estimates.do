*Unit test for pt_pick_type

use "$test_data", clear


*Executing pt_regress
if "$master_set_ado" == "" do "$host_ado"

*Creating count and tt event outocmes
set seed 1000
gen cid = mod(_n,10)
gen count_outcome = rpoisson(3)
gen time_to = rpoisson(365)
gen tt_event = cond(time_to < 356, 1, 0)
replace time_to = 365 if time_to >365


regress qol treat 
pt_su_estimates treat 
di "`r(est)' `r(p)' `r(icc)'"
assert "`r(est)'" == "1.0 (-1.0, 3.0)"
assert "`r(p)'" == "0.34"
assert "`r(icc)'" == ""

mixed qol treat || cid:
pt_su_estimates treat, icc decimal(2) 
di "`r(est)' `r(p)' `r(icc)'"
assert "`r(est)'" == "0.97 (-1.01, 2.95)"
assert "`r(p)'" == "0.34"
assert "`r(icc)'" == "<0.0001"


logit gender treat
pt_su_estimates treat
di "`r(est)' `r(p)' `r(icc)'"
assert "`r(est)'" == "-0.1 (-0.3, 0.2)"
assert "`r(p)'" == "0.56"
assert "`r(icc)'" == ""



melogit gender treat || cid:
pt_su_estimates treat, exp icc decimal(2)
di "`r(est)' `r(p)' `r(icc)'" 
assert "`r(est)'" == "0.93 (0.72, 1.19)"
assert "`r(p)'" == "0.56"
assert "`r(icc)'" == "<0.0001"

nbreg count_outcome treat, irr
pt_su_estimates treat
di "`r(est)' `r(p)' `r(icc)'" 
assert "`r(est)'" == "1.0 (0.9, 1.1)"
assert "`r(p)'" == "0.81"
assert "`r(icc)'" == ""

stset time_to, failure(tt_event)
stcox treat
pt_su_estimates treat
di "`r(est)' `r(p)' `r(icc)'" 
assert "`r(est)'" == "1.1 (0.9, 1.3)"
assert "`r(p)'" == "0.50"
assert "`r(icc)'" == ""

streg treat, distribution(w)
pt_su_estimates treat
di "`r(est)' `r(p)' `r(icc)'" 
assert "`r(est)'" == "1.1 (0.9, 1.3)"
assert "`r(p)'" == "0.50"
assert "`r(icc)'" == ""


