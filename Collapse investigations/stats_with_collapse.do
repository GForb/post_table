cap prog drop calc_stats_with_collapse
prog calc_stats_with_collapse 
    syntax varlist, stats(string) [by(passthru) count_missing]
    foreach stat in `stats' {
        local reshape_stub `reshape_stub' `stat'_
        local collapse_args `collapse_args' (`stat')
        foreach var of varlist `varlist' {
            local collapse_args `collapse_args' `stat'_`var' = `var'
        }
    }
    collapse (count) N = all_obs_indicator `collapse_args', `by'
    gen i = _n
    reshape long `reshape_stub', i(i `over_var') j(variable) string 
    foreach stat in `stats'{
        rename `stat'_ `stat'
    }
    if "`count_missing'" != "" {
        replace count = N - count
    }
end

cap prog drop calc_stats_catagorical_with_collapse
prog calc_stats_catagorical_with_collapse 
    syntax varname, stats(string) [by(string) count_missing]
    foreach stat in `stats' {
        local reshape_stub `reshape_stub' `stat'_
        local collapse_args `collapse_args' (`stat')
        foreach var of varlist `varlist' {
            local collapse_args `collapse_args' `stat'_`var' = `var'
        }
    }
    collapse (count) N = all_obs_indicator `collapse_args', by(`varlist' `by')
    gen i = _n
    reshape long `reshape_stub', i(i `over_var') j(variable) string 
    foreach stat in `stats'{
        rename `stat'_ `stat'
    }
    if "`count_missing'" != "" {
        replace count = N - count
    }
end



clear
set obs 100
set seed 12341324
gen test_variable = rnormal(0, 1)
gen test_variable2 = rnormal(0, 1)
gen test_bin_var = rbinomial(1, 0.5)
gen treat = rbinomial(1, 0.5)
replace test_variable = . if _n <=10
gen all_obs_indicator = 1


calc_stats_with_collapse test_variable test_variable2 , stats(mean sd count p25 p50 p75 max min) by(treat) count_missing