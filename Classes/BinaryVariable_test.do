clear
set obs 100
set seed 1241234
gen test_variable = rbinomial(1, 0.5)
replace test_variable = . if _n <= 10
tab test_variable

discard
.test_variable = .BinaryVariable.new test_variable
.test_variable.calculate_stats

assert `.test_variable.n_all_records' == 100

assert `.test_variable.n_distinct_nonmissing' == 2

assert `.test_variable.positive' == 1
assert `.test_variable.n' == 51
assert "`.test_variable.percent'" == "56.7"
assert "`.test_variable.n_percent'" == "51 (56.7)"
assert "`.test_variable.summary'" == "51 (56.7)"

assert "`.test_variable.summary_comp_brackets'" == "51 (56.7) [90]"



.test_variable2 = .BinaryVariable.new test_variable, decimal_places(0) percent_sign label("TEST") positive(0)
.test_variable2.calculate_stats
assert "`.test_variable2.variable_label'" == "TEST"
assert `.test_variable2.positive' == 0
assert `.test_variable2.n' == 39
assert "`.test_variable2.percent'" == "43%"
assert "`.test_variable2.n_percent'" == "39 (43%)"
assert "`.test_variable2.summary'" == "39 (43%)"

