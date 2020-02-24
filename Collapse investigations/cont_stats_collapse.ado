prog get_summary_cont
    syntax varname, [by(passthru) decimal_places(passthru) summary(string) completeness_args] 
    cont_stats_collapse `varlist', `by' `decimal_places'
    create_completeness_summary, `completeness_args'
    keep variable treat completeness_summary


prog cont_stats_collapse
    syntax varlist, [by(passthru) decimal_places(integer 1)]
    tempvar all_obs_indicator
    gen `all_obs_indicator' = 1
    local stats mean sd count p25 p50 p75 max min
    foreach stat in `stats' {
        local reshape_stub `reshape_stub' `stat'_
        local collapse_args `collapse_args' (`stat')
        foreach var of varlist `varlist' {
            local collapse_args `collapse_args' `stat'_`var' = `var'
        }
    }
    collapse (count) N = `all_obs_indicator' `collapse_args', `by'
    gen i = _n
    reshape long `reshape_stub', i(i) j(variable) string 
    gen completeness_count = count_
    foreach stat in `stats'{
        gen `stat' = string(`stat'_, "%12.`decimal_places'f")
        drop `stat'_
    }
    gen median = p50
	gen mean_sd = mean + " (" + sd + ")"
	gen median_q1q3 = p50 + " (" + p25 + " - " + p75 + ")"
    gen minmax = min + " - " + max
	gen mean_sd_minmax = mean_sd + " [" + minmax + "]"
    
end
