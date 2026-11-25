*run this program imediately following any regression command
*posts results from logistic regression as well as mean (sd) for each group to post file
*the reference treatment group must be the second of the treatment variables.
*version 0.3

prog define pt_subgroup
syntax varlist(numeric max = 1), postname(string) ///
	sub_var(varname) ///
	[ ///
	type(string) ///
	treat(varname) treat_grps(numlist) compare(string) ///
	sub_grps(numlist) ///
	gap(integer 0)  ///
	su_decimal(integer 1) est_decimal(integer 1) miss_decimal(integer 1) decimal(integer 1) ///
	positive(integer 1) ///
	missing(string) ///
	n_analysis(string) ///
	su_label(string) su_label_text(string) ///
	append_label(string) var_lab(string) ///
	per ///
	exp /// exponate results from regression
	icc /// calculate and report icc from analysis
	int_test_false /// report p-values for each subgroup level, rather than ineraction p-value
	use_outcome_label /// uses outcome label rather than subgroup label
	descriptive /// no model: summaries only, with empty estimate and p-value cells
	nodepvarcheck /// allow an outcome that is not the model's outcome, e.g. summaries of y after a model of log(y)
	level(cilevel) /// confidence level for the estimates; default as set by set level
	nolevelcheck /// allow a level() different from the model's
	]

	*model_eform: the model reported ratios (e.g. stcox, logistic, logit with or), so the
	*estimates are exponentiated as if exp had been given (read before r() is overwritten)
	local model_eform = 0
	if "`descriptive'" == "" {
		tempname T
		cap mat `T' = r(table)
		local have_table = !_rc
		if `have_table' {
			*the model's confidence level, worked back from its results table, must match level()
			pt_model_level `T'
			local model_level = r(level)
			if "`levelcheck'" == "" & `model_level' < . & abs(`model_level' - `level') > 0.005 {
				local ml = string(`model_level', "%9.0g")
				di as error "The model's confidence intervals are at `ml'%, but level() is `level'% (the default is set by set level)."
				di as error "Add level(`ml') to match the model, or the nolevelcheck option if this is intended."
				exit 198
			}
			local er = rownumb(`T', "eform")
			if `er' < . {
				forvalues k = 1/`=colsof(`T')' {
					if `T'[`er', `k'] == 1 local model_eform = 1
				}
			}
		}
	}
	if `model_eform' local exp exp

	if "`descriptive'" == "" & "`depvarcheck'" == "" pt_check_depvar `varlist'
	if "`descriptive'" == "" {
		*every estimate here combines coefficients with lincom, which after mi estimate uses
		*complete-data degrees of freedom, so intervals would be too narrow
		if "`e(mi)'" == "mi" {
			di as error "Estimates that combine coefficients (three or more arms, a later timepoint or a subgroup) after mi estimate are not currently supported."
			di as error "If you would like this, please open an issue at https://github.com/GForb/post_table/issues or contact the package developers."
			exit 198
		}
		if "`e(cmd)'" == "mixed" & "`e(dfmethod)'" == "repeated" {
			di as error "dfmethod(repeated) gives no degrees of freedom for a combination of coefficients, such as the treatment effect at a later timepoint or between two non-reference arms."
			di as error "Refit the model with dfmethod(residual), dfmethod(anova), dfmethod(satterthwaite) or dfmethod(kroger)."
			exit 198
		}
	}

	local exclude_p exclude_p
	if "`int_test_false'" != "" {
		local exclude_p ""
	}

	local v `varlist' // setting v to be varlist (varlist is refered to as v throughout).
		
	if "`treat'" == "" local treat treat // sets default treatment parameter
	if "`descriptive'" == "" {
		if `have_table' pt_check_equations `T' `treat'
	}
	if "`treat_grps'" == "" qui levelsof `treat', local(treat_grps)
	if "`per'" != "" local per % //sets whether % sign is included with percentages


	if "`exp'" != "" {
		local exp1 exp(
		local exp2 )
	}
	*storing treatment group values as grp1, grp2...
	local grps: word count `treat_grps'
	forvalues n = 1 (1) `grps' {
		local grps`n': word `n' of `treat_grps'
	}
	
	*three or more arms: the comparisons must be given, as a trial's analysis plan names them
	if `grps' > 2 & `"`compare'"' == "" {
		di as error "With three or more arms, give the comparisons to report with compare(), for example compare(2v1 3v1)."
		di as error "Each comparison is two arm values joined by v, meaning the first arm minus the second."
		exit 198
	}

	*setting the comparisons to report (descriptive: one pass, no comparisons)
	local n_comp = 1
	if "`descriptive'" == "" {
		pt_compare, treat(`treat') treat_grps(`treat_grps') compare(`compare')
		local n_comp = r(n)
		forvalues c = 1 (1) `n_comp' {
			local a`c' `r(a`c')'
			local b`c' `r(b`c')'
			local comp_label`c' `"`r(label`c')'"'
		}
	}
	*a header row names each comparison when there are more than two arms, or the comparison was chosen
	local comp_headers = (`grps' > 2 | `"`compare'"' != "") & "`descriptive'" == ""

	*setting sub group values
	if "`sub_grps'" == "" qui levelsof `sub_var', local(sub_grps)

	*setting decimal values
	if `su_decimal' ==1 local su_decimal = `decimal'
	if `est_decimal' ==1 local est_decimal = `decimal'
	if `miss_decimal' ==1 local miss_decimal = `decimal'
		
	*Generating variable which indicates which observations were included in the analysis
	tempvar inanalysis
	tempname inan_label
	if "`descriptive'" == "" gen `inanalysis' = e(sample)
	else gen `inanalysis' = !missing(`v')
	label var `inanalysis' "In analysis?"
	label define `inan_label' 1 "Included in analysis" 0 "Excluded from analysis"
	label values `inanalysis' `inan_label' 



	*collecting ICC from the model
	if "`icc'" == "" local post_icc ""
	if "`icc'" != "" & "`descriptive'" != "" local post_icc ("")
	if "`icc'" != "" & "`descriptive'" == "" {
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
	
	*extracting variable labels
	local var_label "`var_lab'" // storing variable label in local macro
	if "`var_lab'" == "" {
		if "`use_outcome_label'" == "" {
			get_label_or_var `sub_var'
			local var_label `r(label)'
		}  
		if "`use_outcome_label'" != "" {
			get_label_or_var `v'
			local var_label `r(label)'
		} 
	
	}

		

		
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
	
	local blank_measure_post `measure_post'
	local blank_summaries `summaries'
	local blank_miss_cols `miss_cols'
	local blank_inan_cols `inan_cols'

	*title row, when each comparison has its own header row
	if `comp_headers' {
		post `postname' ("`var_label'`measure_append' `append_label'") `measure_post' `inan_cols' `miss_cols' `summaries' ("") ("") `post_icc'
		if "`icc'" != "" local post_icc ("")
	}

	*extracting the value labels for sub grps (the numeric value if there is no label)
	foreach i in `sub_grps' {
		local sub_lab`i' : label (`sub_var') `i'
	}

	*all sub group levels in the model, for the interaction test
	qui levelsof `sub_var' if `inanalysis' == 1, local(model_sub_grps)

	local form_est %12.`est_decimal'f // setting the format for estimates
	
	*lincom and test only use the df method of a mixed model if asked to
	local small ""
	if "`e(cmd)'" == "mixed" & "`e(dfmethod)'" != "" local small small
	
	forvalues c = 1 (1) `n_comp' {
		local a `a`c''
		local b `b`c''
		
		*get p value for interaction
		local p_int ("")
		if "`int_test_false'" == "" & "`descriptive'" == "" {
			local constraints ""
			foreach k in `model_sub_grps' {
				local constraints `constraints' (`a'.`treat'#`k'.`sub_var' = `b'.`treat'#`k'.`sub_var')
			}
			test `constraints', `small' // joint test across all sub group levels
			local p_int_val = r(p)
			format_p, p(`p_int_val')
			local p_int_str  `r(p_string)'
			local p_int ("`p_int_str'")
		}
		
		*header row
		local header_label "`var_label'`measure_append' `append_label'"
		if `comp_headers' local header_label "  `comp_label`c''"
		di `"posting: ("`header_label'") `blank_measure_post' `blank_inan_cols' `blank_miss_cols' `blank_summaries' ("") `p_int' `post_icc'"'	
		post `postname' ("`header_label'") `blank_measure_post' `blank_inan_cols' `blank_miss_cols' `blank_summaries' ("") `p_int' `post_icc'
		if "`icc'" != "" local post_icc ("") // the icc is for the whole model, so is only posted once

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
			if "`descriptive'" != "" local estimate_post_string ("") ("")
			else {
				local eform ""
				if "`exp'" != "" local eform eform
				lincom (`a'.`treat' + `a'.`treat'#`k'.`sub_var') - (`b'.`treat' + `b'.`treat'#`k'.`sub_var'), `eform' `small' level(`level')
				get_ests_from_lincom, est_decimal(`est_decimal') `exclude_p'
				local estimate_post_string  `r(post_string)'
				di "Lincom post string: " `estimate_post_string'
			}

			*descriptive categorical outcomes: a row for the subgroup level, then one row per category
			if "`descriptive'" != "" & "`type1'" == "cat" {
				local measure_append ""
				if "`su_label'" == "append" {
					local measure1 "no. (%)"
					if "`missing'" == "brackets" local measure1 "`measure1' [missing]"
					if "`n_analysis'" == "brackets" local measure1 "`measure1' [no. included in analysis]"
					if "`su_label_text'" != "" local measure1 `su_label_text'
					local measure_append " - `measure1'"
				}
				post `postname' ("    `sub_lab`k'' `measure_append' `append_sub_lab'") `blank_measure_post' `blank_inan_cols' `blank_miss_cols' `blank_summaries' ("") ("") `post_icc'
				pt_desc_cat `v' if `inanalysis' == 1 & `sub_var' == `k', all_if(`sub_var' == `k') postname(`postname') ///
					treat(`treat') treat_grps(`treat_grps') indent("        ") ///
					su_label(`su_label') su_label_text(`su_label_text') missing(`missing') n_analysis(`n_analysis') per(`per') ///
					su_decimal(`su_decimal') miss_decimal(`miss_decimal') `icc'
				continue
			}
			
			


		*Other variable types

			*Getting summareis (first comparison only, so they are not repeated)
			local inan_cols `blank_inan_cols'
			local miss_cols `blank_miss_cols'
			local summaries `blank_summaries'
			local measure_append ""
			local measure_post `blank_measure_post'
			if `c' == 1 {
				get_summaries `v' if `inanalysis' == 1 & `sub_var' == `k', all_if(`sub_var' == `k') treat(`treat') treat_grps(`treat_grps') type(`type1') ///
					missing(`missing') n_analysis(`n_analysis')  ///
					var_label(`"`var_label'"') su_decimal(`su_decimal') miss_decimal(`miss_decimal') ///
					positive(`positive') per(`per') ///
					su_label_text(`su_label_text') su_label(`su_label')
					
				local inan_cols `r(inan_cols)'
				local miss_cols  `r(miss_cols)'
				local summaries  `r(summaries)'
				local measure_append  `r(measure_append)'
				local measure_post `r(measure_post)'
			}

			local indent "    "
			*posting results
			di `"posting: ("`indent'`sub_lab`k'' `measure_append' `append_sub_lab'") `measure_post' `inan_cols' `miss_cols' `summaries' `estimate_post_string' `post_icc'"'
			post `postname' ("`indent'`sub_lab`k'' `measure_append' `append_sub_lab'") `measure_post' `inan_cols' `miss_cols' `summaries' `estimate_post_string' `post_icc'

		}
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
		di "`exclude_p'"
		di "`p_str'"
			
		
		local post_string `"("`coef' (`ll', `ul')")  ("`p_str'")"'
		return local post_string `post_string'

end

prog get_icc, rclass
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
	
	return local post_icc "`icc_str'"
end

prog get_summaries, rclass
	syntax varlist [if/], all_if(string) treat(string) treat_grps(numlist)  type(string)  su_decimal(integer) miss_decimal(integer) ///
	[positive(integer 1) per(string) su_label_text(string) su_label(string) var_label(string) missing(string)  n_analysis(string) ]
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
			qui count if `treat' == `i' & `all_if'
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
				local per_str = string(`percent', "%12.`su_decimal'f")
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

prog get_label_or_var, rclass
syntax varname

	 local var_label: variable label `varlist'
	 if `"`var_label'"' == "" local var_label "`varlist'"
	 return local label `var_label'
end
