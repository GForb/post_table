*generating data for tests

clear
set obs 1000
set seed 2341234
gen test_variable = rnormal(1 , 1)
gen binary_test_variable = rbinomial(1, 0.2)


*number_as_string
number_as_string 1.5 1
assert "`s(number_as_string)'" == "1.5"

number_as_string 1.5 0
assert "`s(number_as_string)'" == "2"

number_as_string 1.5 2
assert "`s(number_as_string)'" == "1.50"



*statistic as string

statistic_from_tabstat_as_string test_variable, stats(mean) decimal_places(1)
di  `"`s(mean_as_string)'"'
assert `"`s(mean_as_string)'"' == "1.0"

statistic_from_tabstat_as_string test_variable, stats(p25) decimal_places(1)
assert `"`s(p25_as_string)'"' == "0.3"

statistic_from_tabstat_as_string test_variable, stats(median) decimal_places(3)
assert `"`s(median_as_string)'"' == "0.998"

statistic_from_tabstat_as_string test_variable, stats(max) decimal_places(0)
assert `"`s(max_as_string)'"' == "4"

statistic_from_tabstat_as_string test_variable, stats(mean p25 median max) decimal_places(1)
assert `"`s(mean_as_string)'"' == "1.0"
assert `"`s(max_as_string)'"' == "4.5"
assert `"`s(p25_as_string)'"' == "0.3"
assert `"`s(median_as_string)'"' == "1.0"

*mean (sd)
mean_sd_as_string test_variable, decimal_places(1)
di `"`s(mean_sd_as_string)'"'
assert `"`s(mean_sd_as_string)'"' == "1.0 (1.0)"

mean_sd_as_string test_variable, decimal_places(0)
assert `"`s(mean_sd_as_string)'"' == "1 (1)"


mean_sd_as_string test_variable, decimal_places(2)
assert `"`s(mean_sd_as_string)'"' == "0.98 (1.02)"

*median q1 q3
median_q1q3_as_string test_variable, decimal_places(1)
di `"`s(median_q1q3_as_string)'"'
assert `"`s(median_q1q3_as_string)'"' == "1.0 (0.3-1.7)"

median_q1q3_as_string test_variable, decimal_places(0)
assert `"`s(median_q1q3_as_string)'"' == "1 (0-2)"


median_q1q3_as_string test_variable, decimal_places(2)
assert `"`s(median_q1q3_as_string)'"' == "1.00 (0.29-1.70)"

*count_and_percentage
count_positives_as_string binary_test_variable, decimal_places(1)  positive_value(1)
assert `"`s(n_percent_as_string)'"' == "207 (20.7)"

count_positives_as_string binary_test_variable, decimal_places(0) positive_value(0) percentage_sign
assert `"`s(n_percent_as_string)'"' == "793 (79%)"
