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
assert "`.table_body_test.over_groups'" == "overall"
assert "`.table_body_test.overall'" == ""
assert `.table_body_test.summary_cols_first' == 0
assert `.table_body_test.completeness_cols' == 0
assert `.table_body_test.completeness_brackets' == 0
assert `.table_body_test.cols_by_over_variable' == 0
assert "`.table_body_test.stats'" == "summary"
assert `.table_body_test.n_cols' == 1

.table_body_test.varname = "test_variable"
.table_body_test.get_stats_over, over_value("overall")

assert `"`.table_body_test.get_body'"' == `"("-0.4 (5.2)")"'


*assert `"`.table_body_test.get_completeness, over_value("overall")'"' == `"("90")"'


.table_body_test = .TableBody.new, statistics(summary_comp_brackets)
.table_body_test.varname = "test_variable"

assert `"`.table_body_test.get_body,'"' == `"("-0.4 (5.2) [90]")"'



.table_body_test = .TableBody.new, over(treat)

.table_body_test.varname = "test_variable"
assert "`.table_body_test.over_variable'" == "treat"
assert "`.table_body_test.over_groups'" == "0 1"
assert `.table_body_test.n_cols' == 2


assert `"`.table_body_test.get_body'"' == `"("-0.4 (4.7)") ("-0.5 (5.7)")"'

.table_body_test = .TableBody.new, over(treat) over_groups(2 1 0) overall(last)
.table_body_test.varname = "test_variable"

assert "`.table_body_test.over_groups'" == "2 1 0 overall"
assert `.table_body_test.n_cols' == 4
assert `"`.table_body_test.get_body'"' == `"(". (.)") ("-0.5 (5.7)") ("-0.4 (4.7)") ("-0.4 (5.2)")"'

.table_body_test = .TableBody.new, over(treat) over_groups(2 1 0) overall(first)
.table_body_test.varname = "test_variable"
assert `"`.table_body_test.get_body'"' == `"("-0.4 (5.2)") (". (.)") ("-0.5 (5.7)") ("-0.4 (4.7)")"'

.table_body_test = .TableBody.new, over(treat) over_groups(2 1 0) overall(first) statistics(summary_comp_brackets)
.table_body_test.varname = "test_variable"
assert `"`.table_body_test.get_body'"' == `"("-0.4 (5.2) [90]") (". (.) [0]") ("-0.5 (5.7) [44]") ("-0.4 (4.7) [46]")"'

.table_body_test = .TableBody.new, over(treat) overall(last) statistics(completeness_summary summary)
.table_body_test.varname = "test_variable"
assert `.table_body_test.n_cols' == 6
assert `"`.table_body_test.get_body'"' == `"("46") ("-0.4 (4.7)") ("44") ("-0.5 (5.7)") ("90") ("-0.4 (5.2)")"'

.table_body_test = .TableBody.new, over(treat) overall(last) statistics(summary completeness_summary)  cols_by_over_variable
.table_body_test.varname = "test_variable"
assert `.table_body_test.n_cols' == 6
assert `"`.table_body_test.get_body'"' == `"("-0.4 (4.7)") ("-0.5 (5.7)") ("-0.4 (5.2)") ("46") ("44") ("90")"'
