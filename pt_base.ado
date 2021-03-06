*author gordon forbes
*version: see GIT HUB

capture program drop pt_base

prog define pt_base
syntax varlist(numeric) [if] [in], POSTname(string) ///
	[ ///
	Type(string) /// options: skew (reports median IQR), bin (no %), cont (mean sd), cat (freq by group), misstable table summarising missing values
	count_only /// suppresses percentages reported with binary and catagorical variables
	over(varname) /// specify name for over variable 
	over_grps(numlist) /// specify the values the "over" variable can take and which order they should appear. If over is not specified command produces one summary
	overall(string) /// include a summary column for all observations in addition to those by over group. Can be given as first or last. if first column appears first, if last last obv.
	cat_levels(numlist) /// if variable catagorical levels allows catogories to be customised
	cat_col /// if cat col is specified catagories for catagorical variables are included in a seperate column. For other variable types an extra collumn is added
	cat_tabs(integer 1) ///
	gap(integer 0) /// adds empty rows to baseline table after each variable
	gap_end(integer 0)  /// adds empty rows to baseline table after all variables
	decimal(integer 1) miss_decimal(integer 1) su_decimal(integer 1) /// specify number of decimal places to be used 
	positive(integer 1) /// specifies what a positive is for binary variables, default is 1
	Missing(string)  /// specifies that missing data is to be reported, options are cols, brackets. 
	N_analysis(string) /// Specifies that the numbers with complete data should be reported, options cols, brackets, or append
	order(string) /// options group_sum or group_over. Groups colmns by summary ie. missing data columns then summary columns or groups columns by treatment group.
	sum_cols_first /// puts summary columns before those giving missing data or denominators
	su_label(string) /// su_label has can be append or col. If append is specified adds descrptor for the summary measure to variable label. If col is specified adds descriptor in separate column.
	su_label_text(string) /// Overides default summary labels
	append_label(string) /// appends extra text to variable and summary label
	var_lab(string) /// Overides default variable label
	per /// displays "%" sign in table alongside frequencies
	comment(string) /// adds column to end of table with text contained in string
	]

*************IF****************
if "`if'" != "" | "`in'" != "" {
	preserve
	keep `if' `in'
}
***************************Processing options***********************************

*setting decimal values
if `su_decimal' ==1 local su_decimal = `decimal'
if `miss_decimal' ==1 local miss_decimal = `decimal'		

*Setting default for over and extracting the levels of `over'
if "`over'" != "" {
	if "`over_grps'" == "" levelsof `over', local(over_grps)
	if "`overall'" == "first" local over_grps overall `over_grps'
	if "`overall'" == "last" local over_grps  `over_grps' overall
}
if "`over'" == "" local over_grps overall
 

*setting default for order
if "`order'" == "" local order group_sum
if "`order'" == "group_treat" local order group_over

if "`per'" != "" local per % //sets whether % sign is included with percentages


*Comments
local comment1 `comment'
if "`comment1'" == "no comment" local comment ("")
if "`comment1'" != "" & "`comment1'" != "no comment" local comment ("`comment'")
if "`comment1'" != "" local comment_blank ("")


*Missing
foreach w in `missing' {
	if "`w'" == "brackets" local missing brackets
	if "`w'" == "append" local missing append
	if "`w'" == "cols" local missing cols
	if "`w'" == "%" local miss_per miss_per
	if "`w'" == "cond" local cond cond	
}

*Missing
foreach w in `n_analysis' {
	if "`w'" == "brackets" local n_analysis brackets
	if "`w'" == "append" local n_analysis append
	if "`w'" == "cols" local n_analysis cols
	if "`w'" == "%" local n_analysis_per n_analysis_per
	if "`w'" == "cond" local cond cond	
}

*cat tabs
if `cat_tabs' == 0 {
	local tab1 ""
}
else{
	forvalues t = 1 (1) `cat_tabs' {
		local tab1 = "`tab1'	" 
	}
}

*Creating blank columns
*Cat col
if "`cat_col'" != "" local ccol_blank ("")

local miss_cols_blank ""
local inan_cols_blank ""
local summaries_blank ""
	foreach i in `over_grps' {
		local summaries_blank `summaries_blank' ("")
		if "`n_analysis'" == "cols" local inan_cols_blank `inan_cols_blank' ("")
		if "`missing'" == "cols" local miss_cols_blank `miss_cols_blank' ("")
	}


local measure_post_blank
if "`su_label'" == "col" local measure_post_blank ("")
		

	
		
	

***************************Looping over variables*******************************
foreach v in `varlist' {
	di as result _newline(3) "****** `v' ******" _newline(1)


	*Header for table

	display as text %26s "Group {c |}" /* ///
		*/ as text /* ///
		*/ %19s "N obs. Percent" /* ///
		*/ %24s "N missing Percent"

		di as text "{hline 21}{c +}{hline 43}"
	
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

*Determining whether there is any missing data
	qui count if missing(`v')
	local miss_overall = r(N) // this lcoal macro is used to implement the cond option for missing data and n_analysis

*Processing Variable name
	local var_label `var_lab' 
	if "`var_lab'" == "" local var_label:variable label `v'
	if "`var_label'" == "" local var_label = "`v'"
	local var_label `var_label' `append_label' // adding user specified append to variable label

	*Adding summary labels and measure label
	if "`type1'" == "cont" local measure1 "mean (sd)"
	if "`type1'" == "bin" | "`type1'" == "cat" | "`type1'" == "misstable" {
		local measure1 "n (%)"
		if "`count_only'" != "" local measure1 "n"
	}
	if "`type1'" == "skew"  local measure1 "median (IQR)"
	if "`cond'" == "" | ("`cond'" !="" & `miss_overall' >0) {
		if "`miss_per'" != "" | "`n_analysis_per'" != "" local p " (%)"
		if "`missing'" == "brackets" local measure1 "`measure1' [missing]"
		if "`n_analysis'" == "brackets" local measure1 "`measure1' [N`p']"
	}
	
	if "`su_label_text'" != "" local measure1 `su_label_text'
	if "`su_label'" == "append" local measure_append =" - `measure1'"
	
	local N_append ""
	if "`n_analysis'" == "append" & ("`cond'" =="" |  `miss_overall' > 0) {
		qui count if !missing(`v')
		local N = r(N)
		local per1_str ""
		if "`n_analysis_per'" != "" {
			qui count
			local per1 = `N'/r(N)*100
			local per1_str = string(`per1', "%12.`miss_decimal'f")
			local per1_str " (`per1_str'`per')"
			local per1_lab (%)
		}
		local N_append (N  `per1_lab' = `N'`per1_str')
	}
	local missing_append ""
	if "`missing'" == "append" & ("`cond'" =="" |  `miss_overall' > 0) {
		qui count if missing(`v')
		local m = r(N)
		local per2_str ""
		if "`miss_per'" != "" {
			qui count
			local per2 = `m'/r(N)*100
			local per2_str = string(`per2', "%12.`miss_decimal'f")
			local per2_str " (`per2_str'`per')"
			local per2_lab (%)
		}
		local missing_append (Missing `per2_lab' = `m'`per2_str')
	}
	
	local var_label ("`var_label'`measure_append' `N_append' `missing_append'")
	
	
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
			qui count if  !missing(`v')
			local N_`i' = r(N) // note the local macro N_`i' is used as denominaotr for calculating percentages when type is cat or binary
			qui count if missing(`v')
			local n_missing_`i' = r(N) 
		}
		else {
			qui count if `over' == `i'
			local N_data = r(N)
			qui count if `over' == `i' & !missing(`v')
			local N_`i' = r(N)
			qui count if missing(`v') & `over'==`i'
			local n_missing_`i' = r(N) 
		}

		*Calculating percentages for N and n missing
		local n_inanalysis_per_`i' = `N_`i''/`N_data' *100
		local in_per_`i' = string(`n_inanalysis_per_`i'', "%12.`miss_decimal'f")
		local inanalysis_`i' = `N_`i''
		if "`n_analysis_per'" != "" local inanalysis_`i' `N_`i'' (`in_per_`i''`per')

		local n_missing_per_`i' = `n_missing_`i''/`N_data'*100
		local miss_per_`i' = string(`n_missing_per_`i'', "%12.`miss_decimal'f")
		local missing_`i' = `n_missing_`i''
		if "`miss_per'" != "" local missing_`i' `n_missing_`i'' (`miss_per_`i''`per')
		
		*Displaying results
		display as text %20s abbrev("`i'",20) " {c |}" /* ///
			*/ as result /* ///
			*/ %9.0g `N_`i'' " " %9.0g `n_inanalysis_per_`i'' /* ///
			*/ %14.0g `n_missing_`i'' " " %9.0g `n_missing_per_`i'' 
		
		*Output
		if "`cond'" == "cond" & `miss_overall' == 0 {
			local missing_`i' ""
			local inanalysis_`i'  ""
		}
		
		local brackets_`i' ""
			*Columns
			if "`missing'" == "cols" local miss_cols `miss_cols'  ("`missing_`i''")
			if "`n_analysis'" == "cols" local inan_cols `inan_cols'  ("`inanalysis_`i''")

			*Brackets
			local brackets_`i'
			if "`missing'" == "brackets" local brackets_`i' "[`missing_`i'']"
			if "`n_analysis'" == "brackets" local brackets_`i' "[`inanalysis_`i'']"
		
		if "`cond'" == "cond" & `miss_overall' == 0 local brackets_`i'	""
		}
		
	
	*last line of table
	di as text "{hline 21}{c BT}{hline 43}"
*catagorical variables (done a bit different)
	if "`type1'" == "cat" {
	
		*******Posting variable label and miss counts/inanalysis counts********
		if "`cat_col'" == "" {
			if "`order'" == "group_sum" {
				if "`sum_cols_first'" == "" {
					post  `postname' `var_label' `measure_post' `miss_cols_blank' `inan_cols_blank'  `summaries_blank' `comment' //header line
				}
				else {
					post  `postname' `var_label' `measure_post' `summaries_blank' `miss_cols_blank' `inan_cols_blank' `comment' //header line
				}
			}
			if "`order'" == "group_over" {
				local summaries ""
				foreach i in `over_grps' {
					if "`n_analysis'" == "cols" local treat_cols`i' ("")
					if "`missing'" == "cols" local treat_cols`i' ("") 
					if "`sum_cols_first'" == "" {
						local treat_cols`i' `treat_cols`i''  ("")
					}
					else {
						local treat_cols`i' ("")  `treat_cols`i''   
					}
					local summaries `summaries' `treat_cols`i''
				}	
				post `postname' `var_label' `measure_post'  `summaries' `comment'
				
			}
		}
		**********************
		
		*Calculating counts and percentages for each level of catagorical variable
		if "`over'" != "" tab `v' `over', col  // displaying output
		if "`over'" == "" tab `v'  // displaying output
		local val_label: value label `v' // storing the value label names for catagorical variable in local macro

		local levels "`cat_levels'"
		if "`levels'" == "" qui levelsof `v', local(levels)
	
		local row = 0
		foreach l in `levels' {
			local row = `row' + 1
			*Row label
			if "`val_label'" != "" {
				local value_name: label `val_label' `l'
			}
			if "`val_label'" == "" {
				local value_name `l'
			}
			
			*Summary
			foreach i in `over_grps' {
				if "`i'" == "overall" qui count if `v' == `l'
				if "`i'" != "overall" qui count if `v' == `l' & `over' ==`i'
				local n = r(N)
				if "`count_only'" == "" {
					local percent = `n'/`N_`i''*100
					local per_str = string(`percent', "%12.`su_decimal'f")
					local per_str (`per_str'`per')
				}
				local su_`i' ("`n' `per_str' `brackets_`i''") 
			}
			
			
	
		
		*********Posting***********
			local measure_post2 ""
			if "`su_label'" == "col" {
				local measure_post2 ("")
				local measure_post ""	
			}
			local tab "`tab1'"
			if "`cat_col'" != "" {
				if `row' == 1 {
					local ccol `var_label'
					if "`su_label'" == "col" {
						local measure_post ("`measure1'")
						local measure_post2 ""
					}
				}
				if `row' > 1  {
					local ccol  ("")
					if "`su_label'" == "col" {
						local measure_post ("")
						local measure_post2 ""
					}
				}
				local tab ""
			}

			if "`order'" == "group_sum" {
				*Creating postfile entry
				local summaries "" 
				local miss_cols ""
				local inan_cols ""
				foreach i in `over_grps' {
					local summaries `summaries'  `su_`i''
					if "`missing'" == "cols" local miss_cols `miss_cols' ("`missing_`i''")
					if "`n_analysis'" == "cols" local inan_cols `inan_cols'  ("`inanalysis_`i''")
				}
				
				if "`sum_cols_first'" == "" {
					post `postname' `ccol' `measure_post'  ("`tab'`value_name'") `measure_post2' `inan_cols' `miss_cols' `summaries' `comment_blank'
				}
				else {
					post `postname' `ccol' `measure_post' ("`tab'`value_name'") `measure_post2'   `summaries' `inan_cols' `miss_cols'  `comment_blank'
				}
			}
			if "`order'" == "group_over" {
				local summaries ""
				foreach i in `over_grps' {
					
					local treat_cols`i' ""
					if "`missing'" == "cols" local treat_cols`i' `treat_cols`i''  ("`missing_`i''")
					if "`n_analysis'" == "cols" local treat_cols`i' ("`inanalysis_`i''")
					if "`sum_cols_first'" == "" {
						local treat_cols`i' `treat_cols`i''  `su_`i''
					}
					else {
						local treat_cols`i' `su_`i'' `treat_cols`i''  
					}
					local summaries `summaries' `treat_cols`i''
				}
				post `postname' `ccol' `measure_post' ("`tab'`value_name'") `measure_post2'  `summaries' `comment_blank'
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
			}
	
		*Contnuous variables, median IQR
			if "`type1'" == "skew" {
				di "Group `i'"
				if "`i'" == "overall" tabstat `v', stats(q) save
				if "`i'" != "overall" tabstat `v' if  `over' == `i', stats(q) save
				mat define A = r(StatTotal) 
				local median = string(A[2,1], "%12.`su_decimal'f")
				local q1 = string(A[1,1], "%12.`su_decimal'f")
				local q3 = string(A[3,1], "%12.`su_decimal'f")
				local su_`i' ("`median' (`q1'-`q3') `brackets_`i''") 
			}
			
			*Misstable
			if "`type1'" == "misstable" {
				if "`i'" == "overall" qui count if `v'==.
				if "`i'" != "overall" qui count if `v'==. & `over' == `i'
				scalar count_treat_positive_`i' = r(N)
				local n = count_treat_positive_`i'
				if "`count_only'" == ""{
					if "`i'" == "overall" qui count
					if "`i'" != "overall" qui count if `over' == `i'
					local N_`i'_all = r(N)
					local percent = count_treat_positive_`i'/`N_`i'_all'*100 
					local per_str = string(`percent', "%12.`su_decimal'f")
					local per_str (`per_str'`per')
				}
				local su_`i' ("`n' `per_str' `brackets_`i''") 
			}	
		
		}
		
		if "`type1'" == "bin" {
			if "`over'" != "" tab `v' `over', col // displaying output
			if "`over'" == "" tab `v'  
		}
	

	
	*********Posting***********
			if "`order'" == "group_sum" {
				*Creating postfile entry
				local summaries ""
				foreach i in `over_grps'  {
					local summaries `summaries' `su_`i''
				}
				if "`sum_cols_first'" == "" {
					post `postname' `var_label' `measure_post' `ccol_blank' `inan_cols' `miss_cols' `summaries' `comment'
				}
				else {
					post `postname' `var_label' `measure_post' `ccol_blank' `summaries' `inan_cols' `miss_cols'  `comment'
				}
			}
			
			if "`order'" == "group_over" {
				local summaries ""
				foreach i in `over_grps' {
					if "`n_analysis'" == "cols" local treat_cols`i'  ("`inanalysis_`i''")
					if "`missing'" == "cols" local treat_cols`i' ("`missing_`i''") 
					if "`sum_cols_first'" == "" {
						local treat_cols`i' `treat_cols`i''  `su_`i''
					}
					else {
						local treat_cols`i' `su_`i'' `treat_cols`i''  
					}
					local summaries `summaries' `treat_cols`i''
				}
				post `postname' `var_label'  `measure_post' `ccol_blank' `summaries' `comment'
			}
	}
	
	

*Gaps
	if `gap' > 0 {
		forvalues i = 1 (1) `gap' {
			post `postname' ("") `measure_post_blank' `ccol_blank' `inan_cols_blank' `miss_cols_blank' `summaries_blank' `comment_blank'
		}
	}
}
	
if `gap_end' > 0 {
	forvalues i = 1 (1) `gap_end' {
			post `postname' ("") `measure_post_blank' `ccol_blank' `inan_cols_blank' `miss_cols_blank' `summaries_blank' `comment_blank'
		}
	}

*************IF****************
if "`if'" != "" | "`in'" != ""  restore

	

end
