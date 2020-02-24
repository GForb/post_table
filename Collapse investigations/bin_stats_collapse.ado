prog bin_stats_collapse
    syntax varlist, [by(passthru) count_missing positive(integer 1)]
        foreach var of varlist `varlist' {
            tempvar `var'_indicator
            gen ``var'_indicator' = 1 if `var' == `positive'
            local collapse_vars `collapse_vars' `var' ``var'_indicator'
        }
    tempvar N 
    gen `N'  = 1
    
    collapse (count) `N'  `collapse_vars', `by'
    rename `N' N
    foreach var in `varlist' {
        rename ``var'_indicator' positive_`var'
        rename `var' count_`var'
    }
    gen i = _n
    reshape long count_ positive_, i(i) j(variable) string
    rename count_ completeness_count
    rename positive_ n
end
