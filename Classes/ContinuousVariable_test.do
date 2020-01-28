discard
clear
set obs 100
set seed 12341324
gen test_variable = rnormal(0, 1)
replace test_variable = . if _n <=10

.test_variable = .ContinuousVariable.new test_variable
.test_variable.calculate_stats

assert `.test_variable.n_all_records' == 100


assert `.test_variable.n_distinct_nonmissing' == 90

assert "`.test_variable.mean'" == "-0.1"
assert "`.test_variable.sd'" == "1.0"
assert "`.test_variable.median'" == "-0.2"
assert "`.test_variable.q1'" == "-0.8"
assert "`.test_variable.q3'" == "0.8"
assert "`.test_variable.min'" == "-2.6"
assert "`.test_variable.max'" == "2.0"
assert "`.test_variable.mean_sd'" == "-0.1 (1.0)"
assert "`.test_variable.median_q1q3'" == "-0.2 (-0.8 - 0.8)"
assert "`.test_variable.minmax'" == "-2.6 - 2.0"
assert "`.test_variable.mean_sd_minmax'" == "-0.1 (1.0) [-2.6 - 2.0]"
assert "`.test_variable.summary'" == "-0.1 (1.0)"
