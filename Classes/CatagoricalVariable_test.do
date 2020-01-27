clear
set obs 100
set seed 1241234
gen latent_variable = rnormal(0, 1)
egen test_variable =  cut(latent_variable), group(5)
replace test_variable = . if _n <= 10
tab test_variable

discard
.test_variable = .CatagoricalVariable.new test_variable
.test_variable.get_stats

assert `.test_variable.n_all_records' == 100

assert `.test_variable.n_missing' == 10
assert "`.test_variable.percent_missing'" == "10.0"
assert "`.test_variable.n_percent_missing'" == "10 (10.0)"

assert `.test_variable.n_complete' == 90
assert "`.test_variable.percent_complete'" == "90.0"
assert "`.test_variable.n_percent_complete'" == "90 (90.0)"

assert `.test_variable.n_distinct_nonmissing' == 5

assert `.test_variable.levels.arrnels' == 5
assert `.test_variable.n.arrnels' == 5
assert `.test_variable.percent.arrnels' == 5
assert `.test_variable.n_percent.arrnels' == 5
assert `.test_variable.summary.arrnels' == 5


assert `.test_variable.levels[1]' == 0
assert `.test_variable.levels[5]' == 4 

assert `.test_variable.n[2]' == 17
assert `.test_variable.n[3]' == 19

assert "`.test_variable.percent[4]'" == "18.9"
assert "`.test_variable.percent[2]'" == "18.9"

assert "`.test_variable.n_percent[3]'" == "19 (21.1)"
assert "`.test_variable.n_percent[1]'" == "19 (21.1)" 

assert "`.test_variable.summary[4]'" == "17 (18.9)"
assert "`.test_variable.summary[5]'" == "18 (20.0)"

.test_variable2 = .CatagoricalVariable.new test_variable, decimal_places(2) percent_sign
.test_variable2.get_stats

assert `.test_variable2.levels.arrnels' == 5
assert `.test_variable2.n.arrnels' == 5
assert `.test_variable2.percent.arrnels' == 5
assert `.test_variable2.n_percent.arrnels' == 5
assert `.test_variable2.summary.arrnels' == 5


assert `.test_variable2.levels[1]' == 0
assert `.test_variable2.levels[5]' == 4 

assert `.test_variable2.n[2]' == 17
assert `.test_variable2.n[3]' == 19

assert "`.test_variable2.percent[4]'" == "18.89%"
assert "`.test_variable2.percent[2]'" == "18.89%"

assert "`.test_variable2.n_percent[3]'" == "19 (21.11%)"
assert "`.test_variable2.n_percent[1]'" == "19 (21.11%)" 

assert "`.test_variable2.summary[4]'" == "17 (18.89%)"
assert "`.test_variable2.summary[5]'" == "18 (20.00%)"