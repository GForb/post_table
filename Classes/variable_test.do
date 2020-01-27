discard
clear
set obs 100
set seed 12341324
gen test_variable = rnormal(0, 1)
replace test_variable = . if _n <=10

.test_variable = .Variable.new test_variable 

assert "`.test_variable.varname'" == "test_variable"
assert "`.test_variable.variable_label'" == "test_variable"
assert `.test_variable.decimal_places' == 1
assert "`.test_variable.percent_sign'" == ""

.test_variable.get_stats

assert `.test_variable.n_all_records' == 100

assert `.test_variable.n_missing' == 10
assert "`.test_variable.percent_missing'" == "10.0"
assert "`.test_variable.n_percent_missing'" == "10 (10.0)"

assert `.test_variable.n_complete' == 90
assert "`.test_variable.percent_complete'" == "90.0"
assert "`.test_variable.n_percent_complete'" == "90 (90.0)"

assert `.test_variable.n_distinct_nonmissing' == 90
 
.test_variable = .Variable.new test_variable, label ("Test") decimal_places(0) percent_sign

assert "`.test_variable.varname'" == "test_variable"
assert "`.test_variable.variable_label'" == "Test"
assert `.test_variable.decimal_places' == 0
assert "`.test_variable.percent_sign'" == "%"

.test_variable.get_stats

assert `.test_variable.n_all_records' == 100

assert `.test_variable.n_missing' == 10
assert "`.test_variable.percent_missing'" == "10%"
assert "`.test_variable.n_percent_missing'" == "10 (10%)"

assert `.test_variable.n_complete' == 90
assert "`.test_variable.percent_complete'" == "90%"
assert "`.test_variable.n_percent_complete'" == "90 (90%)"

assert `.test_variable.n_distinct_nonmissing' == 90
 
