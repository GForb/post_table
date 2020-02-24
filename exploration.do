cap prog drop number_as_string
prog define number_as_string, sclass
sreturn clear
args number decimal_places
	local number_as_string = string(`number', "%12.`decimal_places'f")
	sreturn clear
	sreturn local number_as_string `number_as_string'

end

cap prog drop statistic_from_tabstat_as_string
prog define statistic_from_tabstat_as_string, sclass
syntax varname, stats(string) decimal_places(integer)
	
	tabstat `varlist', stats(`stats') save
	local i = 1
	foreach statistic in `stats' {
		local value_of_statistic = r(StatTotal)[`i', 1]
		number_as_string `value_of_statistic' `decimal_places'
		local `statistic'_as_string `s(number_as_string)'
		local i = `i' + 1
	}
	
	sreturn clear
	foreach statistic in `stats' {
		sreturn local `statistic'_as_string ``statistic'_as_string'
	}
	
	
end

prog get_stats_as_string
syntax varname, decimal_places
	su `var', detail
	foreach statistic in mean  sd min max p25 p50 p75 {
		local statistic = r(`statistic')
		local `statistic'_as_string = string(`statistic', "%12.`decimal_places'f")
	}
	return clear
	foreach statistic in mean  sd min max p25 p50 p75 {
		retrun local `statistic'_as_string ``statistic'_as_string'
	}
end
	

cap prog drop mean_sd_as_string
prog define mean_sd_as_string, sclass
syntax varname, decimal_places(passthru)
	
	statistic_from_tabstat_as_string `varlist', stats(mean sd) `decimal_places'
	local mean_sd `s(mean_as_string)' (`s(sd_as_string)')
	
	sreturn clear
	sreturn local mean_sd_as_string `mean_sd'
end


cap prog drop median_q1q3_as_string
prog define median_q1q3_as_string, sclass
syntax varname, decimal_places(passthru)
	
	statistic_from_tabstat_as_string `varlist', stats(median p25 p75) `decimal_places'
	local median_q1q3 `s(median_as_string)' (`s(p25_as_string)'-`s(p75_as_string)')
	
	sreturn clear
	sreturn local median_q1q3_as_string `median_q1q3'
end

cap prog drop count_positives_as_string
prog define count_positives_as_string, sclass
syntax varname, decimal_places(integer) positive_value(real) [percentage_sign]
	count if `varlist' == `positive_value'
	local n = r(N)
	number_as_string `n' 0
	local n_as_string `s(number_as_string)'
	count if `varlist' != .
	local N = r(N)
	local percentage = `n'/`N'*100
	number_as_string `percentage' `decimal_places'
	if "`percentage_sign'" != "" {
		local percentage_sign %
	}
	local n_percent `n_as_string' (`s(number_as_string)'`percentage_sign')
	
	sreturn clear
	sreturn local n_percent_as_string `n_percent'
end
