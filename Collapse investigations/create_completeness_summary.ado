prog create_completeness_summary 
    syntax, [missing include_percent decimal_places(iteger 1) percent_sign]
    rename count completeness_count
    if "`percent_sign'" != "" lcoal percent_sign  %
    if "`missing'" != . replace completeness_count = N - completeness_count
    if include_percent != "" {
        gen completeness_percent = coupletness_count/N*100
        completeness_summary = string(completeness_count, "%12.0f") + " (" + string(completeness_percent, "%12.`.decimal_places'f") + "`percent_sign')"    
    }
    else {
        completeness_summary = string(completeness_count, "%12.0f")
    }
    drop N completeness_count completeness_percent
    
end
