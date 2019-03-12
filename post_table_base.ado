*author gordon forbes
*version: see GIT HUB

capture program drop post_table_base

prog define post_table_base
syntax varlist(numeric) [if], postname(string) ///
	[ ///
	type(string) /// options: skew (reports median IQR), bin (no %), cont (mean sd), cat (freq by group)
	count_only /// suppresses percentages reported with binary and catagorical variables
	over(varname) /// specify name for over variable 
	over_grps(numlist) /// specify the values the "over" variable can take and which order they should appear. If over is not specified command produces one summary
	overall(string) /// include a summary column for all observations in addition to those by over group. Can be given as first or last. if first column appears first, if last last obv.
	cat_levels(numlist) /// if variable catagorical levels allows catogories to be customised
	gap(integer 0) /// adds empty rows to baseline table after each variable
	gap_end(integer 0)  /// adds empty rows to baseline table after all variables
	decimal(integer 1) miss_decimal(integer 1) su_decimal(integer 1) /// specify number of decimal places to be used 
	positive(integer 1) /// specifies what a positive is for binary variables, default is 1
	missing(string)  /// specifies that missing data is to be reported, options are cols, brackets. 
	miss_per /// include percentage in missing data summary
	n_analysis(string) /// Specifies that the numbers with complete data should be reported, options cols or brackets or append
	n_analysis_per /// include percentage in missing data summary
	order(string) /// options group_sum or group_treat. Groups colmns by summary ie. missing data columns then summary columns or groups columns by treatment group.
	su_label(string) /// su_label has can be append or col. If append is specified adds descrptor for the summary measure to variable label. If col is specified adds descriptor in separate column.
	su_label_text(string) /// Overides default summary labels
	append_label(string) /// appends extra text to variable and summary label
	var_lab(string) /// Overides default variable label
	per /// displays "%" sign in table alongside frequencies
	comment(string) /// adds column to end of table with text contained in string
	]

*************IF****************
if "`if'" != "" {
	preserve
	keep `if'
}
***************************Processing options***********************************

*setting decimal values
if `su_decimal' ==1 local su_decimal = `decimal'
if `miss_decimal' ==1 local est_decimal = `decimal'		

*Setting default for over and extracting the levels of `over'
if "`over'" != "" {
	if "`over_grps'" == "" levelsof `over', local(over_grps)
	if "`overall'" == "first" local over_grps overall `over_grps'
	if "`overall'" == "last" local over_grps  `over_grps' overall
}
if "`over'" == "" local over_grps overall
 

*setting default for order
if "`order'" == "" local order group_sum

if "`per'" != "" local per % //sets whether % sign is included with percentages


*Comments
if "`comment'" != "" & "`comment'" != "no comment" local comment ("`comment'")
if "`comment'" == "no comment" local comment ("")



***************************Looping over variables*******************************
foreach v in `varlist' {
	di _newline(3) "****** `v' ******" _newline(1)

*Auto detecting type of variable. (this is very crude) - note r(N_unique) equals missing when there  are more than 99 unique values.
local type1 = "`type'" // resetting type variable to be that given by command
	if "`type1'" == "" {
		qui inspect `v'
		if r(N_unique) < 3 {
			local type1 = "bin"
		}
		else if r(N_unique) < 10 {
			local type1 = "cat"
		}
		else if r(N_unique) >= 10 | r(N_unique) ==. {
			local type1 = "cont"
		}
	}
	
*Processing Variable name
	local var_label `var_lab' 
	if "`var_lab'" == "" local var_label:variable label `v'
	if "`var_label'" == "" local var_label = "`v'"
	local var_label `var_label' `append_label' // adding user specified append to variable label

	*Adding summary labels and measure label
	if "`type1'" == "cont" local measure1 "mean (sd)"
	if "`type1'" == "bin" | "`type1'" == "cat" {
		local measure1 "n (%)"
		if "`count_only'" != "" local measure1 "n"
	}
	if "`type1'" == "skew"  local measure1 "median (IQR)"
	if "`missing'" == "brackets" local measure1 "`measure1' [missing]"
	if "`n_analysis'" == "brackets" local measure1 "`measure1' [n included in analysis]"
	
	if "`su_label_text'" != "" local measure1 `su_label_text'
	if "`su_label'" == "append" local measure_append =" - `measure1'"
	if "`n_analysis'" == "append" {
		qui count if missing(`v') ==0
		local N = r(N)
		local N_append (N = `N')
	}
	local var_label ("`var_label'`measure_append' `N_append'")
	
	
	*Adding column if measure label to be included as column
	local measure_post
	if "`su_label'" == "col" local measure_post ("`measure1'")
	
*Missing data and denominators
	local miss_cols "" // resetting columns
	local inan_cols ""
	foreach i in `over_grps' {
		*Counts
		if "`i'" == "overall" {
			qui count
			local N_data = r(N)
			qui count if  missing(`v') ==0
			local N_`i' = r(N) // note the local macro N_`i' is used as denominaotr for calculating percentages when type is cat or binary
			qui count if missing(`v') ==1
			local n_missing_`i' = r(N) 
		}
		else {
			qui count if `over' == `i'
			local N_data = r(N)
			qui count if `over' == `i' & missing(`v') ==0
			local N_`i' = r(N)
			qui count if missing(`v') ==1 & `over'==`i'
			local n_missing_`i' = r(N) 
		}

		*Calculating percentages for N and n missing
		local n_inanalysis_per_`i' = `N_`i''/`N_data' *100
		local in_per_`i' = string(`n_inanalysis_per_`i'', "%12.`miss_decimal'f")
		local inanalysis_`i' = `N_`i''
		if "`n_analysis_per'" != "" local inanalysis_`i' `N_`i'' (in_per_`i'`per')

		local n_missing_per_`i' = `n_missing_`i''/`N_data'*100
		local miss_per_`i' = string(`n_missing_per_`i'', "%12.`miss_decimal'f")
		local missing_`i' = `n_missing_`i''
		if "`miss_per'" != "" local missing_`i' `n_missing_`i'' (`miss_per_`i''`per')
		
		*Displaying results
		di "Group  `i'" _newline "n obs:" as result `n_per_`i'' " `n_inanalysis_per_`i''%"
		di "n missing:" as result `n_missing_`i'' " `miss_per_`i''%" _newline(2)
		
		*Columns
		if "`missing'" == "cols" local miss_cols `miss_cols'  ("`missing_`i''")
		if "`n_analysis'" == "cols" local inan_cols `inan_cols'  ("`inanalysis_`i''")

		*Brackets
		if "`missing'" == "brackets" local brackets_`i' "[`missing_`i'']"
		if "`n_analysis'" == "brackets" local brackets_`i' "[`inanalysis_`i'']"
	}
	

*catagorical variables (done a bit different)
	if "`type1'" == "cat" {
	
		*******Posting variable label and miss counts/inanalysis counts********
		if "`order'" == "group_sum" {
			local summaries ""
			foreach i in `over_grps' {
				local summaries `summaries'  ("")
			}
			if "`sum_cols_first'" == "" {
				post  `postname' `var_label' `measure_post' `miss_cols' `inan_cols'  `summaries' `comment' //header line
			}
			else {
				post  `postname' `var_label' `measure_post' `summaries' `miss_cols' `inan_cols' `comment' //header line
			}
		}
		if "`order'" == "group_treat'" {
			local summaries ""
			foreach i in `over_grps' {
				if "`n_analysis'" == "cols" ("`inanalysis_`i''")
				if "`missing'" == "cols" local over_cols`i' ("`missing_`i''") 
				local treat_cols`i' ("`missing_`i''")  ("")
				local summaries `summaries' treat_cols`i'
			}	
			post `postname' `var_label' `measure_post'  `summaries' `comment'
				
		}
	
		**********************
		
		*Calculating counts and percentages for each level of catagorical variable
		if "`over'" != "" tab `v' `over', col // displaying output
		if "`over'" == "" tab `v'  // displaying output
		local val_label: value label `v' // storing the value label names for catagorical variable in local macro

		local levels "`cat_levels'"
		if "`levels'" == "" qui levelsof `v', local(levels)
		if "`missing'" == "brackets"  local levels `levels' miss
		if "`n_analysis'" == "brackets" local levels `levels' inan
	
		foreach i in `levels' {	
			*Row label
			if "`i'" == "inan" {
				local value_name "n included in analysis"
			}
			else if "`i'" == "miss" {
				local value_name "missing" //value for missing data
			}
			else {
				if "`val_label'" != "" {
					local value_name: label `val_label' `i'
				}
				if "`val_label'" == "" {
					local value_name `i'
				}
			}
			
			*Summary
			foreach j in `over_grps' {
				if "`i'" != "inan" & "`i'" != "miss" {
					if "`j'" == "overall" qui count if `v' == `i'
					if "`j'" != "overall" qui count if `v' == `i' & `over' ==`j'
					local n = r(N)
					if "`count_only'" == "" {
						local percent = `n'/`N_`j''*100
						local per_str = string(`percent', "%12.`su_decimal'f")
						local per_str (`per_str'`per')
					}
					local su_`j' ("`n' `per_str'") 
				}
				if "`i'" == "inan" | "`i'" == "miss" local su_`j' ("`brackets_`j''")
			}
			
			
	
		
		*********Posting***********
			if "`su_label'" == "col" local measure_post ("")

			if "`order'" == "group_sum" {
				*Creating postfile entry
				local summaries "" 
				local miss_cols ""
				local inan_cols ""
				foreach j in `over_grps' {
					local summaries `summaries'  `su_`j''
					if "`missing'" == "cols" local miss_cols `miss_cols'  ("")
					if "`n_analysis'" == "cols" local inan_cols `inan_cols'  ("")	
				}
				
				if "`sum_cols_first'" == "" {
					post `postname' ("	`value_name'") `measure_post' `inan_cols' `miss_cols' `summaries' `comment'
				}
				else {
					post `postname' ("	`value_name'") `measure_post' `summaries' `inan_cols' `miss_cols'  `comment'
				}
			}
			if "`order'" == "group_treat'" {
				local summaries ""
				foreach j in `over_grps' {
					if "`n_analysis'" == "cols" local treat_cols`j' ("")
					if "`missing'" == "cols" local treat_cols`j' `treat_cols`j'' ("") 
					local treat_cols`i' `treat_cols`j''  su_`j'
					local summaries `summaries' `treat_cols`j''
				}
				post `postname' ("     `value_name'") `measure_post'  `summaries' `comment'
			}
		}
	} 
	else {

*Other variable types
	foreach i in `over_grps' {
			
		*Continuous variables, mean sd	
		if "`type1'" == "cont" {
			di "Group `i'"
			if "`i'" == "overall" su `v' 
			if "`i'" != "overall" su `v' if  `over' == `i'
			local mean = string(r(mean), "%12.`su_decimal'f")
			local sd = string(r(sd), "%12.`su_decimal'f")
			local su_`i' ("`mean' (`sd') `brackets_`i''")  
		}
	
		*Binary variables
		if "`type1'" == "bin" {
			if "`i'" == "overall" qui count if `v'==`positive'
			if "`i'" != "overall" qui count if `v'==`positive' & `over' == `i'
			scalar count_treat_positive_`i' = r(N)
			local n = count_treat_positive_`i'
			if "`count_only'" == ""{	
				local percent = count_treat_positive_`i'/`N_`i''*100  // N_`i' is taken from denominators section
				local per_str = string(`percent', "%12.`su_decimal'f")
				local per_str (`per_str'`per')
			}
			
			local su_`i' ("`n' `per_str' `brackets_`i''") 
			if "`over'" != "" tab `v' `over', col // displaying output
			if "`over'" == "" tab `v'  // displaying output 
			
	}
	
	*Contnuous variables, median IQR
		if "`type1'" == "skew" {
			di "Group `i'"
			if "`i'" == "overall" tabstat `v' if  `over' == `i', stats(q) save
			if "`i'" != "overall" tabstat `v' if  `over' == `i', stats(q) save
			mat define A = r(StatTotal) 
			local median = string(A[2,1], "%12.`su_decimal'f")
			local q1 = string(A[1,1], "%12.`su_decimal'f")
			local q3 = string(A[3,1], "%12.`su_decimal'f")
			local su_`i' ("`median' (`q1'-`q3') `brackets_`i''") 
		}
	}
	
	
	
	*********Posting***********
			if "`order'" == "group_sum" {
				*Creating postfile entry
				local summaries ""
				foreach i in `over_grps'  {
					local summaries `summaries' `su_`i''
				}
				if "`sum_cols_first'" == "" {
					post `postname' `var_label' `measure_post' `inan_cols' `miss_cols' `summaries' `comment'
				}
				else {
					post `postname' `var_label' `measure_post' `summaries' `inan_cols' `miss_cols'  `comment'
				}
			}
			
			if "`order'" == "group_treat'" {
				local summaries ""
				foreach i in `over_grps' {
					if "`n_analysis'" == "cols" ("`inanalysis_`i''")
					if "`missing'" == "cols" local treat_cols`i' ("`missing_`i''") 
					local treat_cols`i' ("`missing_`i''")  su_`i'
					local summaries `summaries' treat_cols`i'
				}
				post `postname' `var_label' `measure_post'  `summaries' `comment'
			}
	}
	
	

*Gaps
	local measure_post
	if "`su_label'" == "col" local measure_post ("")

	local summaries ""
	local miss_cols ""
	local inan_cols ""
	foreach i in `over_grps' {
		local summaries `summaries' ("")
		if "`missing'" == "cols" local miss_cols `miss_cols'  ("")
		if "`n_analysis'" == "cols" local inan_cols `inan_cols'  ("")
		
		
	}
	if "`comment'" != "" local comment ("")
		
	if `gap' > 0 {
		forvalues i = 1 (1) `gap' {
			post `postname' ("") `measure_post' `inan_cols' `miss_cols' `summaries' `comment'
		}
	}
}
	
if `gap_end' > 0 {
	forvalues i = 1 (1) `gap_end' {
			post `postname' ("") `measure_post' `inan_cols' `miss_cols' `summaries' `comment'
		}
	}

*************IF****************
if "`if'" != "" restore

	

end
