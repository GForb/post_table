discard
clear
set obs 100
set seed 12341324
gen test_variable = rnormal(0, 5)
replace test_variable = . if _n <=10

gen treat = rbinomial(1, 0.5)

.test_variable = .ContinuousVariable.new test_variable

.table_body_test = .TableBody.new 
assert "`.table_body_test.over_variable'" == ""
assert "`.table_body_test.over_groups'" == ""
assert "`.table_body_test.overall'" == ""
assert `.table_body_test.summary_cols_first' == 0
assert `.table_body_test.completeness_cols' == 0
assert `.table_body_test.completeness_brackets' == 0
assert "`.table_body_test.stats'" == "summary"
assert `.table_body_test.n_cols' == 1
assert "`.table_body_test.group_cols_by'" == "over_variable"

.table_body_test.variable = "test_variable"
assert `"`.table_body_test.get_summary test_variable'"' == `"("-0.4 (5.2)")"'

.table_body_test.completeness_brackets = 1
assert `"`.table_body_test.get_summary test_variable'"' == `"("-0.4 (5.2) [90]")"'



.table_body_test = .TableBody.new, over(treat_variable)
assert "`.table_body_test.over_variable'" == "treat"
assert "`.table_body_test.over_grps'" == "0 1"
assert `.table_body_test.n_cols' == 2

`"`.table_body_test.get_body test_variable'"' == `""-0.4 (4.7)" "-0.5 (5.7)""'

.table_body_test = .TableBody.new, over(treat_variable) over_groups(2 1 0) overall(last)
assert "`.table_body_test.over_grps'" == "2 1 0"
assert "`.table_body_test.overall'" == "last"
assert `.table_body_test.n_cols' == 4
`"`.table_body_test.get_body test_variable'"' == `""0.0 (0.0)" "-0.5 (5.7)" "-0.4 (4.7)" "-0.4 (5.2)""'




