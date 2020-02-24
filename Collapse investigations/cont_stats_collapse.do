prog cont_stats_collapse
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
