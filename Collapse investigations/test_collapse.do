*continuous
clear
set obs 100
set seed 12341324
gen test_variable = rnormal(0, 1)
gen test_variable2 = rnormal(0, 1)

gen treat = rbinomial(1, 0.5)
replace test_variable = . if _n <=10

cap prog drop cont_stats_collapse
cont_stats_collapse test_variable test_variable2 , by(treat) 
cap prog drop create_completeness_summary
create_completeness_summary, include_percent


*binary
cap prog drop bin_stats_collapse
clear
set obs 100
set seed 12341324
gen test_bin = rbinomial(1, 0.5)
gen test_bin2 = rbinomial(1, 0.3)

gen treat = rbinomial(1, 0.5)
replace test_bin = . if _n <=10

bin_stats_collapse test_bin test_bin2,  by(treat) count_missing
cap prog drop create_completeness_summary
create_completeness_summary, include_percent missing decimal_places(0) percent_sign

*catagorical
cap prog drop catagorical_stats_collapse
clear
set obs 100
set seed 12341324
gen test_bin = rbinomial(1, 0.5)
gen test_bin2 = rbinomial(1, 0.3)
gen test_bin3 = rbinomial(1, 0.3)
gen treat = rbinomial(1, 0.5)
replace test_bin = . if _n <=10

catagorical_stats_collapse test_bin test_bin2 test_bin3, by(treat)

cap prog drop create_completeness_summary
create_completeness_summary