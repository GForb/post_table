*run this program imediately following any regression command
*posts results from logistic regression as well as mean (sd) for each group to post file
*the reference treatment group must be the second of the treatment variables.
*version 0.3

prog define pt_subgroup
syntax varlist(numeric max = 1), postname(string) ///
	sub_var(varname) ///
	[ ///
	type(string) ///
	treat(varname) treat_grps(numlist) prim_treat(integer -10000) ///
	sub_grps(numlist) prim_sub_grp(integer -10000) ///
	gap(integer 0)  ///
	su_decimal(integer 1) est_decimal(integer 1) miss_decimal(integer 1) decimal(integer 1) ///
	positive(integer 1) ///
	positive(integer 1) ///
	missing(string) ///
	n_analysis(string) ///
	su_label(string) su_label_text(string) ///
	append_label(string) var_lab(string) ///
	per ///
	exp /// exponate results from regression
	icc /// calculate and report icc from analysis
	no_interaction_test /// report p-values for each subgroup level, rather than ineraction p-value
	use_outcome_label /// uses outcome label rather than subgroup label
	]
		
	local exclude_p exclude_p
	if "`no_interaction_test'" != "" {
		local exclude_p ""
	}

	local v `varlist' // setting v to be varlist (varlist is refered to as v throughout).
		
	if "`treat'" == "" local treat treat // sets default treatment parameter
	if "`treat_grps'" == "" qui levelsof `treat', local(treat_grps)
	if "`per'" != "" local per % //sets whether % sign is included with percentages

	if e(cmd) == "regress" {
		local df = e(df_r) // setting the degrees of freedom to be used following regress
		local tdist = 1
	}

	if "`exp'" != "" {
		local exp1 exp(
		local exp2 )
	}
	*storing treatment group values as grp1, grp2...
	local grps: word count `treat_grps'
	forvalues n = 1 (1) `grps' {
		local grps`n': word `n' of `treat_grps'
		if "`max_grps'" == "" local max_grps = `grps`n''
		local max_grps = max(`max_grps', `grps`n'')
	}
	*setting primary treatment group (as opposed to the reference group)
	if `prim_treat' < -9999 local prim_treat = `max_grps'
	

	*storing sub group values as sub_grp1, sub_grp2...
	if "`sub_grps'" == "" qui levelsof `sub_var', local(sub_grps)
	local grps_s: word count `sub_grps'
	forvalues n = 1 (1) `grps_s' {
		local sub_grps`n': word `n' of `sub_grps'
		if "`max_sub_grps'" == "" local max_sub_grps = `sub_grps`n''
		local max_sub_grps = max(`max_sub_grps', `sub_grps`n'')
	}
	
	if `prim_sub_grp' < -9999 local prim_sub_grp = `max_sub_grps' // storing max as this is reference group for use in interaction test

	*setting decimal values
	if `su_decimal' ==1 local su_decimal = `decimal'
	if `est_decimal' ==1 local est_decimal = `decimal'
	if `miss_decimal' ==1 local miss_decimal = `decimal'
		
	*Generating variable which indicates which observations were included in the analysis
	tempvar inanalysis
	tempname inan_label
	gen `inanalysis' = e(sample)
	label var `inanalysis' "In analysis?"
	label define `inan_label' 1 "Included in analysis" 0 "Excluded from analsis"
	label values `inanalysis' `inan_label' 



	*collecting ICC from the model
	if "`icc'" == "" local post_icc ""
	if "`icc'" != "" {
		get_icc
		local post_icc =r(post_icc)
		local post_icc ("`post_icc'")
		
	}


	local type1 `type'
	*auto detecting type of variable (this is very crude)
	if "`type1'" == "" {
		get_type `v'
		local type1 `r(type)'
	}
	
	set trace on 
	*extracting variable labels
	local var_label "`var_lab'" // storing variable label in local macro
	
	if "`var_lab'" == "" {
		if "`use_outcome_label'" == ""  local var_label: variable label `sub_var'
		if "`use_outcome_label'" != ""  local var_label: variable label `v'
	
	} 
	set trace off
		

		
	*posting header row
	if "`su_label'" == "col" local measure_post ("")
	local summaries ""
	foreach i in `treat_grps' {
		local summaries `summaries'  ("")
	}
		
	if "`missing'" == "cols" {
		local miss_cols ""
		foreach i in `treat_grps' {
			local miss_cols `miss_cols' ("")
		}
	}
		
	if "`n_analysis'" == "cols" {
		local inan_cols ""
		foreach i in `treat_grps' {
			local inan_cols `inan_cols' ("")
		}
	}
	
	*get p value for interaction
	local p_int ("")
	if "`no_interaction_test'" != "" {
		lincom `prim_treat'.`treat'#`prim_sub_grp'.`sub_var'
		local p_int_val = r(p)
		format_p, p(`p_int')
		local p_int_str = r(p_string)
		local p_int ("`p_int_str'")
	}
	di `"posting: ("`var_label'`measure_append' `append_label'") `measure_post' `inan_cols' `miss_cols' `summaries' ("") `p_int' `post_icc'"'	
	post `postname' ("`var_label'`measure_append' `append_label'") `measure_post' `inan_cols' `miss_cols' `summaries' ("") `p_int' `post_icc'

	*extracting the value labels for sub grps
	local val_label: value label `sub_var' // storing the value labels of treat
	foreach i in `sub_grps' {
		local sub_lab`i': label `val_label' `i'
	}


	local form_est %12.`est_decimal'f // setting the format for estimates
	*posting data
	foreach k in `sub_grps'{
		di

		di
		
		if "`missing'" != "" {
			di "numbers included/excluded form analysis in sub group `var_label' = `sub_lab`k''"
			tab `inanalysis' `treat' if `sub_var' == `k' , col
		}
		if "`n_analysis'" != "" {
			di "numbers included/excluded form analysis in sub group `var_label' = `sub_lab`k''"
			tab `inanalysis' `treat' if `sub_var' == `k', col
		}
		


		
		*Extracting estiamtes
		local eform ""
		if "`exp'" != "" local eform ,eform
		lincom `prim_treat'.`treat' + `prim_treat'.`treat'#`k'.`sub_var' `eform' 
		get_ests_from_lincom, est_decimal(`est_decimal') `exclude_p'
		local estimate_post_string = r(post_string)
		


	*Other variable types

		*Getting summareis
		get_summaries `v' if `inanalysis' == 1 & `sub_var' == `k', treat(`treat') treat_grps(`treat_grps') type(`type1') ///
			missing(`missing') n_analysis(`n_analysis')  ///
			var_label(`var_label') su_decimal(`su_decimal') ///
			positive(`positive') `percent' ///
			su_label_text(`su_label_text') su_label(`su_label')
			
		local inan_cols `r(inan_cols)'
		local miss_cols  `r(miss_cols)'
		local summaries  `r(summaries)'
		local measure_append  `r(measure_append)'
		local measure_post `r(measure_post)'


		*posting results
		di `"posting: ("`sub_lab`k'' `measure_append' `append_sub_lab'") `measure_post' `inan_cols' `miss_cols' `summaries' `estimate_post_string' `post_icc'"'
		post `postname' ("`sub_lab`k'' `measure_append' `append_sub_lab'") `measure_post' `inan_cols' `miss_cols' `summaries' `estimate_post_string' `post_icc'

		}

		*setting marcros for posting gaps
		 // following lines enact measure option
		if "`su_label'" == "col" local measure_post ("")
		local summaries ""
		foreach i in `treat_grps' {
			local summaries `summaries'  ("")
		}
		
		if "`missing'" == "cols" {
			local miss_cols ""
			foreach i in `treat_grps' {
				local miss_cols `miss_cols' ("")
			}
		}
		
		if "`n_analysis'" == "cols" {
			local inan_cols ""
			foreach i in `treat_grps' {
				local inan_cols `inan_cols' ("")
			}
		}
		
		if "`icc'" != "" local post_icc ("")

	if `gap' > 0 {
		forvalues i = 1 (1) `gap' {
			post `postname' ("") `measure_post' `inan_cols' `miss_cols'  `summaries' ("") ("") `post_icc'
		}
	}

end

prog define get_type, rclass
syntax varlist

	qui inspect `varlist'
	if r(N_unique) < 3 {
		local type1 = "bin"
	}
	else if r(N_unique) < 10 {
		local type1 = "cat"
	}
	else if r(N_unique) >= 10 | r(N_unique) ==. {
		local type1 = "cont"
	}
	di "variable type for `varlist': `type1'"
	return local type "`type1'"
end

prog format_p, rclass
syntax , p(real)
	di `p'
	if `p' >=0.01 {
		local p_int = string(`p', "%3.2f")
	}
	if `p' >=0.001 & `p' < 0.01 {
		local p_int = string(`p', "%4.3f")
	}
	if `p' < 0.001 {
		local p_int = "<0.001"
	}
	
	return local p_string `"`p_int'"'

end

prog get_ests_from_lincom, rclass
syntax, est_decimal(integer) [exclude_p]
		local form_est %12.`est_decimal'f
		local coef = r(estimate)
		local ll = r(lb)
		local ul = r(ub)
		
		local coef = string(`coef', "`form_est'")
		local ll = string(`ll', "`form_est'")
		local ul = string(`ul', "`form_est'")
		
		if "`exclude_p'" == "" {
			local p = r(p)
			format_p, p(`p')
			local p_str = r(p_string)
		}

		if "`exclude_p'" != "" local p_str ""

			
		
		local post_string `"("`coef' (`ll', `ul')")  ("`p_str'")"'
		return local post_string `post_string'

end

prog get_icc
	estat icc
	local icc = r(icc2)
	
	if `icc' >=0.01 {
		local icc_str = string(`icc', "%3.2f")
	}
	if `icc' >=0.001 & `icc' < 0.01 {
		local icc_str = string(`icc', "%4.3f")
	}
	if `icc' < 0.001 {
		local icc_str = "<0.001"
	}
	
	local post_icc ("`icc_str'")
	return local post_icc `"post_icc"'
end

prog get_summaries, rclass
	syntax varlist [if/], treat(string) treat_grps(numlist)  type(string)  su_decimal(integer) ///
	[positive(integer 1) percent su_label_text(string) su_label(string) var_label(string) missing(string)  n_analysis(string) ]
		local v `varlist'
		local type1 `type'
		
		local if_statement ""
		local and_if ""
		if `"`if'"' != "" {
			local if_statement if `if'
			local and_if & `if'
		}
		
		if "`type1'" == "bin" {
			di "`v' in sub group `var_label' = `sub_lab'"
			tab `v' `treat' `if_statement', col 
		}
		
		
		*storing missing values in local variables
		foreach i in `treat_grps' {
			qui count if `treat' == `i' `and_if'
			local n_inanalysis_`i' = r(N)
			qui count if `treat' == `i' `and_if'
			local n_missing_`i' = r(N) - `n_inanalysis_`i''
			local n_missing_per_`i' = `n_missing_`i''/r(N)*100
			if "`missing'" == "brackets" local str_missing "[`n_missing_`i'']"
			if "`n_analysis'" == "brackets" local str_missing "[`n_inanalysis_`i'']"
				
				*Continuous variable	
			if "`type1'" == "cont" {
				di "Treatment group " `i' ", sub group  `var_label' = `sub_lab`k''"
				su `v' if  `treat' == `i' `and_if'
				local mean = string(r(mean), "%12.`su_decimal'f")
				local sd = string(r(sd), "%12.`su_decimal'f")
				local su_`i' "`mean' (`sd') `str_missing' `str_inanalysis'" 
				local measure1 "mean (sd)" 
			}
		
		*Binary variables
			if "`type1'" == "bin" {
				qui count if `treat' == `i' `and_if'
				scalar count_treat_`i' = r(N)
				qui count if `v'==`positive' & `treat' == `i' `and_if'
				scalar count_treat_positive_`i' = r(N)
				local n = count_treat_positive_`i'
				local percent = count_treat_positive_`i'/count_treat_`i'*100
				local per_str = string(`percent', "%2.`su_decimal'f")
				local su_`i' "`n' (`per_str'`per') `str_missing' `str_inanalysis'" 
				local measure1 "no. (%)"
			}
			
			if "`type1'" == "skew" {
				di "Treatment group " `i' ", sub group  `var_label' = `sub_lab`k''"
				tabstat `v' if  `treat' == `i' `and_if' , stats(q) save
				mat define A = r(StatTotal) 
				local median = string(A[2,1], "%12.`su_decimal'f")
				local q1 = string(A[1,1], "%12.`su_decimal'f")
				local q3 = string(A[3,1], "%12.`su_decimal'f")
				local su_`i' "`median' (`q1'-`q3') `str_missing' `str_inanalysis'" 
				local measure1 "median (IQR)"
			}
			
		if "`missing'" == "brackets" local measure1 "`measure1' [missing]"
		if "`n_analysis'" == "brackets" local measure1 "`measure1' [no. included in analysis]"	
		
		}
		
		local measure_post ""
		local measure_append ""
		
		if "`su_label_text'" != "" local measure1 `su_label_text'
		if "`su_label'" == "col" local measure_post ("`measure1'")
		if "`su_label'" == "append" local measure_append =" - `measure1'"
		
		*creating entry in post file for summaries
		local summaries ""
		foreach i in `treat_grps' {
			local temp `su_`i''
			local summaries `summaries'  ("`temp'")
		}
		
		local miss_cols ""
		if "`missing'" == "cols" {
			foreach i in `treat_grps' {
				local miss_per = string(`n_missing_per_`i'', "%12.`miss_decimal'f")
				local temp `n_missing_`i'' (`miss_per'`per')
				local miss_cols `miss_cols'  ("`temp'")
			}
		}
		
		local inan_cols ""
		if "`n_analysis'" == "cols" {
			foreach i in `treat_grps' {
				local inan_cols `inan_cols'  ("`n_inanalysis_`i''")
			}
		}
		
		di `"summaries: "'
		
		return local inan_cols `"`inan_cols'"'
		return local miss_cols `"`miss_cols'"'
		return local summaries `"`summaries'"'
		return local measure_append `"`measure_append'"'
		return local measure_post `"`measure_post'"'



end
