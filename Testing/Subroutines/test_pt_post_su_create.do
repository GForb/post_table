*Test for pt_post_su_create

if "$master_set_ado" == "" do "$host_ado" // executing ado file if required
use "$test_data", clear // loading test data


local test ("1") ("2")
tokenize `test'
di `"`1'"'

di  _newline(1) "Test `++test'"
pt_post_summaries_create, su(("su1") ("su2") ("su3")) 
assert `"`r(sum)'"' == `"("su1") ("su2") ("su3")"'

di  _newline(1) "Test `++test'"
pt_post_summaries_create, su(("su1") ("su2") ("su3")) n(("n1") ("n2") ("n3")) 
assert `"`r(sum)'"' == `"("n1") ("n2") ("n3") ("su1") ("su2") ("su3")"'

di  _newline(1) "Test `++test'"
pt_post_summaries_create, su(("su1") ("su2") ("su3")) n(("n1") ("n2") ("n3")) sum_cols_first
assert `"`r(sum)'"' == `"("su1") ("su2") ("su3") ("n1") ("n2") ("n3")"'

di  _newline(1) "Test `++test'"
pt_post_summaries_create, su(("su1") ("su2") ("su3")) n(("n1") ("n2") ("n3")) order(group_over)
assert `"`r(sum)'"' == `"("n1") ("su1") ("n2") ("su2") ("n3") ("su3")"'

di  _newline(1) "Test `++test'"
pt_post_summaries_create, su(("su1") ("su2") ("su3")) n(("n1") ("n2") ("n3")) order(group_over) sum_cols_first
assert `"`r(sum)'"' == `"("su1") ("n1") ("su2") ("n2") ("su3") ("n3")"'
