*Tests for pt_base paths not covered by the comprehensive examples

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

cd "$pt_root/Testing/pt_base"

*Test 1: categorical variables with order(group_over) and no cat_col, including one without value labels
*Input data made by Testing/make_input_data.do: eg_data2 plus ethnicity_nolab
use "$pt_root/Testing/pt_base/Input data/pt_base_extra_input.dta", clear

tempname postname
tempfile results
postfile `postname' str100(col1 col2 col3 col4 col5 col6) using `results', replace
pt_base ethnicity ethnicity_nolab, post(`postname') over(treat) over_grps(1 0) type(cat) n_analysis(cols) order(group_over) su_label(col)
postclose `postname'

use `results', clear
pt_check using "pt_base_extra_test1_reference.dta", name(pt_base_extra:test1)
