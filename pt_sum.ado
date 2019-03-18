capture program drop pt_sum

prog define pt_sum
syntax varlist(numeric) [if], postname(string) stats(namelist) ///
	[ ///
	over(varname) ///
	over_grps(numlist) ///
	overall(string) ///
	order(string) ///
	gap(integer 0) /// adds empty rows to baseline table after each variable
	gap_end(integer 0)  /// adds empty rows to baseline table after all variables
	decimal(integer 1) ///
	range_decimal(integer 1) /// specify number of decimal places to be used for range
	med_iqr_decimal(integer 1) /// specify number of decimal places to be used for median and IQR
	append_label(string) /// appends extra text to variable label
	var_lab(string) /// Overides default variable label
	comment(string) /// adds column to end of table with text contained in string
	]

*************IF****************
if "`if'" != "" {
	preserve
	keep `if'
}

***************************Processing options***********************************
	

*Setting default for over and extracting the levels of `over'
if "`over'" != "" {
	if "`over_grps'" == "" levelsof `over', local(over_grps)
	if "`overall'" == "first" local over_grps overall `over_grps'
	if "`overall'" == "last" local over_grps  `over_grps' overall
}
if "`over'" == "" local over_grps overall
 
*setting default for order
if "`order'" == "" local order group_treat

*Checking valid stats specified
local stats_list "N", "missing", "mean_sd", "median_iqr", "range" // list of permited stats
foreach s in `stats' {
	 if inlist("`s'", "`stats_list'") ==0 {
		di "stats option incorrectly specified. stats must be one of: `stats_list'"
		exit
	}
}

*Decimal places
if `range_decimal' ==1 local range_decimal = `decimal'
if `med_iqr_decimal' ==1 local med_iqr_decimal = `decimal'	




***************************Looping over variables*******************************
foreach v in `varlist' {
	*Processing Variable name
	local var_label `var_lab' 
	if "`var_lab'" == "" local var_label:variable label `v'
	local var_label `var_label' `append_label' // adding user specified append to variable label
	local var_label ("`var_label'")
	
	di _newline(3) "****** `v' ******" _newline(1)
	
	foreach i in `over_grps' {
*Implementing command
		di "Group  `i'"
		if "`i'" == "overall" su `v', detail
		if "`i'" != "overall" su `v' if  `over' == `i', detail 
		local N_`i' = r(N)
		foreach s in mean sd  {
			local `s'_`i' = string(r(`s'), "%12.`decimal'f")
		}
		foreach s in  p50 p25 p75 {
			local `s'_`i'  = string(r(`s'), "%12.`med_iqr_decimal'f")
		}
		foreach s in  min max{
			local `s'_`i'  = string(r(`s'), "%12.`range_decimal'f")
		}
		local mean_sd_`i' `mean_`i'' (`sd_`i'')
		local median_iqr_`i' `p50_`i'' (`p25_`i''-`p75_`i'')
		local range_`i' `min_`i'' - `max_`i''
		if "`i'" == "overall" qui count if missing(`v') ==.
		if "`i'" != "overall" qui count if missing(`v') ==. & `over' == `i'
		local missing_`i' = r(N)
	}

	
	*********Posting***********
	if "`order'" == "group_sum" {
		local summaries ""
		foreach s in `stats' {
			foreach i in `over_grps' {
				local summaries `summaries' ("``s'_`i''")
			}
		}
	}
	if "`order'" == "group_treat" {
		local summaries ""
		foreach i in `over_grps' {
			foreach s in `stats' {
				local summaries `summaries' ("``s'_`i''")
			}
		}		
	}
	
	*Comments
	if "`comment'" != "" & "`comment'" != "no comment" local comment ("`comment'")
	if "`comment'" == "no comment" local comment ("")
	
	post `postname' `var_label' `summaries' `comment'

		




*Gaps
	local summaries ""
	foreach i in `over_grps' {
		local summaries `summaries' ("")	
		if "`comment'" != "" local comment ("")
	}
	if `gap' > 0 {
		forvalues i = 1 (1) `gap' {
			post `postname' ("")  `summaries' `comment'
		}
	}
}
	
if `gap_end' > 0 {
	forvalues i = 1 (1) `gap_end' {
			post `postname' ("")  `summaries' `comment'
		}
	}

*************IF****************
if "`if'" != "" restore

end
