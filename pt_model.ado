capture program drop pt_model
*run this program imediately following any regression command
*posts results from logistic regression as well as mean (sd) for each group to post file
*version 0.2

prog define pt_model
syntax varlist(numeric max = 1), postname(string) ///
	[ ///
	treat(varname) treat_grps(numlist) compare(string) ///
    type(string) ///
	gap(integer 0)  ///
	positive(integer 1) ///
	per ///
	missing(string) ///
	n_analysis(string) ///
	su_label(string) su_label_text(string) ///
	append_label(string) var_lab(string) ///
	su_decimal(integer 1) est_decimal(integer 1) miss_decimal(integer 1) decimal(integer 1) ///
	exp /// exponate results from regression
	icc /// calculate and report icc from analysis
	]

	mat A = r(table)
	
if "`treat'" == "" local treat treat // sets default treatment parameter
if "`treat_grps'" == "" qui levelsof `treat', local(treat_grps)
if "`per'" != "" local per % //sets whether % sign is included with percentages
if "`append_label'" != "" local append_label " `append_label'"

if "`exp'" != "" {
	local exp1 exp(
	local exp2 )
}
*storing treatment group values as grp1, grp2...
local grps: word count `treat_grps'
forvalues n = 1 (1) `grps' {
	local grps`n': word `n' of `treat_grps'
}

*setting the comparisons to report
local multi_comp = `grps' > 2 | `"`compare'"' != ""
if `multi_comp' {
	pt_compare, treat(`treat') treat_grps(`treat_grps') compare(`compare')
	local n_comp = r(n)
	forvalues c = 1 (1) `n_comp' {
		local a`c' `r(a`c')'
		local b`c' `r(b`c')'
		local comp_label`c' `"`r(label`c')'"'
	}
	forvalues c = 1 (1) `n_comp' {
		cap lincom `a`c''.`treat' - `b`c''.`treat'
		if _rc {
			di as error "`treat' must be in the model as a factor variable (i.`treat') to compare arms."
			exit 198
		}
	}
}

*With two arms, the estimate is the treatment coefficient in the model results table
local two_arm_lincom = 0
if !`multi_comp' {
	local col = colnumb(A, "`treat'")
	if `col' >= . {
		*factor variable: the arm with a coefficient (the base and omitted arms have no standard error)
		local n_cols = 0
		foreach g in `treat_grps' {
			local k = colnumb(A, "`g'.`treat'")
			if `k' < . {
				if A[2, `k'] < . {
					local col = `k'
					local ++n_cols
				}
			}
		}
		*neither arm is the base level of the model, so no single coefficient compares them
		if `n_cols' == 2 {
			local two_arm_lincom = 1
			pt_compare, treat(`treat') treat_grps(`treat_grps')
			local a1 `r(a1)'
			local b1 `r(b1)'
		}
	}
	if `col' >= . {
		di as error "`treat' not found in the model results. Run pt_model immediately after the model, with `treat' in the model."
		exit 198
	}
}

*setting decimal values
if `su_decimal' ==1 local su_decimal = `decimal'
if `est_decimal' ==1 local est_decimal = `decimal'
if `miss_decimal' ==1 local miss_decimal = `decimal'		


tempvar inanalysis
tempname inan_label
gen `inanalysis' = e(sample)
label var `inanalysis' "In analysis?"
label define `inan_label' 1 "Included in analysis" 0 "Excluded from analysis"
label values `inanalysis' `inan_label' 



local form_est %12.`est_decimal'f
if !`multi_comp' & !`two_arm_lincom' {
	*the table may already be exponentiated, for example after logistic or stcox
	local eform_row = rownumb(A, "eform")
	if `eform_row' < . {
		if A[`eform_row', `col'] == 1 {
			local exp1 ""
			local exp2 ""
		}
	}
	local coef = `exp1'A[rownumb(A, "b"), `col']`exp2'
	local ll = `exp1'A[rownumb(A, "ll"), `col']`exp2'
	local ul = `exp1'A[rownumb(A, "ul"), `col']`exp2'

	local coef = string(`coef', "`form_est'")
	local ll = string(`ll', "`form_est'")
	local ul = string(`ul', "`form_est'")

	scalar p1 = A[rownumb(A, "pvalue"), `col']
	if p1 >=0.01 local p = string(p1, "%3.2f")
	if p1 >=0.001 & p1 < 0.01 local p = string(p1, "%4.3f")
	if p1 < 0.001 local p = "<0.001"
}

if `two_arm_lincom' {
	get_lincom_ests, a(`a1') b(`b1') treat(`treat') form_est(`form_est') `exp'
	local coef `r(coef)'
	local ll `r(ll)'
	local ul `r(ul)'
	local p `r(p)'
}

if "`icc'" != "" {
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
}


*What follows is taken from post_base_beta
local v `varlist'
local var_label "`var_lab'" // storing variable label in local macro
if "`var_lab'" == ""  local var_label:variable label `v'


local type1 = "`type'" // resetting type variable to be that given by 

*auto detecting type of variable (this is very crude)
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

*Other variable types
	if "`type1'" == "bin" 	tab `v' `treat' if  `inanalysis' == 1, col 
	if "`missing'" != "" tab `inanalysis' `treat', col
	if "`n_analysis'" != "" tab `inanalysis' `treat', col
	
	*storing missing values in local variables
	foreach i in `treat_grps' {
			qui count if `treat' == `i' & `inanalysis' ==1
			local n_inanalysis_`i' = r(N)
			qui count if `treat' == `i'
			local n_missing_`i' = r(N) - `n_inanalysis_`i''
			local n_missing_per_`i' = `n_missing_`i''/r(N)*100
			if "`missing'" == "brackets" local str_missing "[`n_missing_`i'']"
			if "`n_analysis'" == "brackets" local str_missing "[`n_inanalysis_`i'']"
			
			*Continuous variable	
		if "`type1'" == "cont" | "`type1'" == "cat" {
			di "Treatment group " `i'
			su `v' if  `treat' == `i'  & `inanalysis' ==1
			local mean = string(r(mean), "%12.`su_decimal'f")
			local sd = string(r(sd), "%12.`su_decimal'f")
			local su_`i' "`mean' (`sd') `str_missing' `str_inanalysis'" 
			local measure1 "mean (sd)" 
		}

	*Binary variables
		if "`type1'" == "bin" {
			qui count if `treat' == `i'  & `inanalysis' ==1
			scalar count_treat_`i' = r(N)
			qui count if `v'==`positive' & `treat' == `i'  & `inanalysis' ==1
			scalar count_treat_positive_`i' = r(N)
			local n = count_treat_positive_`i'
			local percent = count_treat_positive_`i'/count_treat_`i'*100
			local per_str = string(`percent', "%12.`su_decimal'f")

			local su_`i' "`n' (`per_str'`per') `str_missing' `str_inanalysis'" 
			local measure1 "no. (%)"
		}
		
		if "`type1'" == "skew" {
			di "Treatment group " `i'
			tabstat `v' if  `treat' == `i'  & `inanalysis' ==1, stats(q) save
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
	
	

if `multi_comp' post `postname' ("`var_label'`measure_append'`append_label'") `measure_post' `inan_cols' `miss_cols' `summaries' ("") ("")  `post_icc'
else post `postname' ("`var_label'`measure_append'`append_label'") `measure_post' `inan_cols' `miss_cols' `summaries' ("`coef' (`ll', `ul')") ("`p'")  `post_icc'

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

*one row per comparison
if `multi_comp' {
	forvalues c = 1 (1) `n_comp' {
		get_lincom_ests, a(`a`c'') b(`b`c'') treat(`treat') form_est(`form_est') `exp'
		local coef `r(coef)'
		local ll `r(ll)'
		local ul `r(ul)'
		local p `r(p)'
		post `postname' ("    `comp_label`c''") `measure_post' `inan_cols' `miss_cols' `summaries' ("`coef' (`ll', `ul')") ("`p'")  `post_icc'
	}
}

if `gap' > 0 {
	forvalues i = 1 (1) `gap' {
		post `postname' ("") `measure_post' `inan_cols' `miss_cols'  `summaries' ("") ("") `post_icc'
	}
}

end

prog get_lincom_ests, rclass
syntax , a(integer) b(integer) treat(varname) form_est(string) [exp]
	local eform ""
	if "`exp'" != "" local eform eform
	*lincom only uses the df method of a mixed model if asked to
	local small ""
	if "`e(cmd)'" == "mixed" & "`e(dfmethod)'" != "" local small small
	lincom `a'.`treat' - `b'.`treat', `eform' `small'
	return local coef = string(r(estimate), "`form_est'")
	return local ll = string(r(lb), "`form_est'")
	return local ul = string(r(ub), "`form_est'")
	if r(p) >=0.01 local p = string(r(p), "%3.2f")
	if r(p) >=0.001 & r(p) < 0.01 local p = string(r(p), "%4.3f")
	if r(p) < 0.001 local p = "<0.001"
	return local p "`p'"
end
