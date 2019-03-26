*Subroutines
prog define ptsr_p_format, rclass
	if `1' >=0.01 local p = string(`1', "%3.2f")
	if `1' >=0.001 & `1' < 0.01 local p = string(`1', "%4.3f")
	if `1' < 0.001 local p = "<0.001"
	return local p "`p'"
end

prog define ptsr_estimates, rclass
syntax varname, [exp decimal(integer, 1) icc]

mat A = r(table)
if "`exp'" != "" {
	local exp1 exp(
	local exp2 )
}
local col_ov = colnumb(`over')

*Extracting extiamte and confidence interval
foreach r of b ul ll  {
	local row = rownumb(A,"`r'")
	local `r' = `exp1'A[`row',`col_ov']`exp2'
	local `r' = string(`coef', "%12.`est_decimal'f")
}
return local est ("`b' (`ll', `ul')")

*Extracting and formatting p-value
local row_pvalue = rownumb(A,"pvalue")
local p1 = A[`row_pvalue',`col_ov']
ptsr_p_format `p1'
local p r(p)
local p ("`p'")
return local p ("`p'")

*Extractig and storing ICC
if "`icc'" != "" {
	estat icc
	local icc = r(icc2)
	ptsr_p_format `icc'
	local icc_str r(p)
	local post_icc ("`icc_str'")
	return local icc `post_icc'
}
end

prog define ptsr_type 	
syntax varname
qui inspect `varname'
		if r(N_unique) < 3 return local type "bin"
		if r(N_unique) >=3 & r(N_unique) < 10 return local type "cat"
		if r(N_unique) >= 10 | r(N_unique) ==. return local type "cont"
end


prog define ptsr_cat
end
prog define ptsr_bin
end
prog define ptsr_cont varname

end
prog define ptsr_skew
end

capture program drop pt_regress

prog define pt_regress
version 15.1
syntax varlist(numeric max = 1), POSTname(string) ///
	[ ///
	Type(string) 	///
	over(varname) over_grps(numlist) ///
	gap(integer 0)  ///
	su_decimal(integer 1) est_decimal(integer 1) miss_decimal(integer 1) decimal(integer 1) ///
	positive(integer 1) ///
	order(string) /// options group_sum or group_over. Groups colmns by summary ie. missing data columns then summary columns or groups columns by treatment group.
	sum_cols_first /// puts summary columns before those giving missing data or denominators
	n_analysis(string) ///
	su_label(string) su_label_text(string) ///
	append_label(string) var_lab(string) ///
	per ///
	exp /// exponate results from regression
	icc /// calculate and report icc from analysis
	estimates(string) // use command on saved estimates
	]
	
if "`estimates'" != "" est restore `estimates'
tempname est_store
qui est store `est_store'

tempvar inanalysis
tempname inan_label
gen `inanalysis' = e(sample)
label var `inanalysis' "In analysis?"
label define `inan_label' 1 "Included in analysis" 0 "Excluded from analysis"
label values `inanalysis' `inan_label'
	
*setting decimal values
if `su_decimal' ==1 local su_decimal = `decimal'
if `est_decimal' ==1 local est_decimal = `decimal'
if `miss_decimal' ==1 local miss_decimal = `decimal'
	
	
	
/*
This program is split into two sections:
	- Section 1 extracts the estimate, confidence interval and p-value from the model (and ICC if specified).
	- Section 2 produces the summaries to be reported alongside the estimates.
*/

* #1 Extracting estimates
*=========================
ptsr_estimates `over', decimal(`est_decimal') `exp'`icc'
local post_est r(est)
local post_p r(p)
local post_icc r(icc)


*What follows is taken from pt_base

if "`over_grps'" == "" qui levelsof `over', local(treat_grps)
if "`per'" != "" local per % //sets whether % sign is included with percentages
if "`append_label'" != "" local append_label " `append_label"

local v `varlist'
local var_label "`var_lab'" // storing variable label in local macro
if "`var_lab'" == ""  local var_label:variable label `v'


local type1 = "`type'" // resetting type variable to be that given by 

*auto detecting type of variable (this is very crude)
	if "`type1'" == "" {
		ptsr_type `v'
		local type1 r(type)
	}

*Other variable types
	if "`type1'" == "bin" 	tab `v' `over' if  `inanalysis' == 1, col 
	if "`missing'" != "" tab `inanalysis' `over', col
	if "`n_analysis'" != "" tab `inanalysis' `over', col
	
	*storing missing values in local variables
	foreach i in `over_grps' {
			qui count if `over' == `i' & `inanalysis' ==1
			local n_inanalysis_`i' = r(N)
			qui count if `over' == `i'
			local n_missing_`i' = r(N) - `n_inanalysis_`i''
			local n_missing_per_`i' = `n_missing_`i''/r(N)*100
			if "`missing'" == "brackets" local str_missing "[`n_missing_`i'']"
			if "`n_analysis'" == "brackets" local str_missing "[`n_inanalysis_`i'']"
			
			*Continuous variable	
		if "`type1'" == "cont" {
			di "Treatment group " `i'
			su `v' if  `over' == `i'  & `inanalysis' ==1
			local mean = string(r(mean), "%12.`su_decimal'f")
			local sd = string(r(sd), "%12.`su_decimal'f")
			local su_`i' "`mean' (`sd') `str_missing' `str_inanalysis'" 
			local measure1 "mean (sd)" 
		}

	*Binary variables
		if "`type1'" == "bin" {
			qui count if `over' == `i'  & `inanalysis' ==1
			scalar count_treat_`i' = r(N)
			qui count if `v'==`positive' & `over' == `i'  & `inanalysis' ==1
			scalar count_treat_positive_`i' = r(N)
			local n = count_treat_positive_`i'
			local percent = count_treat_positive_`i'/count_treat_`i'*100
			local per_str = string(`percent', "%12.`su_decimal'f")

			local su_`i' "`n' (`per_str'`per') `str_missing' `str_inanalysis'" 
			local measure1 "no. (%)"
		}
		
		if "`type1'" == "skew" {
			di "Treatment group " `i'
			tabstat `v' if  `over' == `i'  & `inanalysis' ==1, stats(q) save
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
	foreach i in `over_grps' {
		local temp `su_`i''
		local summaries `summaries'  ("`temp'")
	}

	local miss_cols ""
	if "`missing'" == "cols" {
		foreach i in `over_grps' {
			local miss_per = string(`n_missing_per_`i'', "%12.`miss_decimal'f")
			local temp `n_missing_`i'' (`miss_per'`per')
			local miss_cols `miss_cols'  ("`temp'")
		}
	}
	
	local inan_cols ""
	if "`n_analysis'" == "cols" {
		foreach i in `over_grps' {
			local inan_cols `inan_cols'  ("`n_inanalysis_`i''")
		}
	}
	
	

post `postname' ("`var_label'`measure_append'`append_label'") `measure_post' `inan_cols' `miss_cols' `summaries' ("`coef' (`ll', `ul')") ("`p'")  `post_icc'

	*setting marcros for posting gaps
	 // following lines enact measure option
	if "`su_label'" == "col" local measure_post ("")
	local summaries ""
	foreach i in `over_grps' {
		local summaries `summaries'  ("")
	}
	
	if "`missing'" == "cols" {
		local miss_cols ""
		foreach i in `over_grps' {
			local miss_cols `miss_cols' ("")
		}
	}
	
	if "`n_analysis'" == "cols" {
		local inan_cols ""
		foreach i in `over_grps' {
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



