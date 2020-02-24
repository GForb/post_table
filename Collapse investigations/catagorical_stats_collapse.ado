prog catagorical_stats_collapse
    syntax varlist, [by(passthru) catagorical_levels(passthru)]
    foreach var of varlist `varlist'{
        preserve
            catagorical_collapse_one_var `var', `by' `catagorical_levels'
            if "`results'" == "" {
                gen variable = "`var'"
            }
            else {
                append using "`results'", gen(from_old)
                replace variable = "`var'" if from_old == 0
                drop from_old
            }
            tempfile results
            save "`results'", replace
        restore
    }
    use `results', clear
end



prog catagorical_collapse_one_var
    syntax varname, [by(string) catagorical_levels(integer 1)]
    if "`by'" != "" {
        local by_option by(`by')
    } 
    preserve
       tempvar all_obs
       gen `all_obs' = 1
       collapse (count) `all_obs' `varlist', `by_option'
       egen i =  group(`by')
       rename `all_obs' N
       rename `varlist' completeness_count
       tempfile denominators
       save `denominators'
    restore
    
    *Obtaining 
    tempvar collapse_by
    gen `collapse_by' = `varlist'
    collapse (count) `varlist', by(`collapse_by' `by')
    rename `varlist' n
    rename `collapse_by' value
    egen i =  group(`by')
    merge m:1 i using "`denominators'"
    drop _merge
    drop if value == .
end
/*
    gen i = _n
    reshape long count_ positive_, i(i) j(variable) string
    rename count_ count
    rename positive_ positive
*/


