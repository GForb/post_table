
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
pt_su_estimates `over', decimal(`est_decimal') `exp'`icc'
local post_est ("`r(est')") ("`r(p)'")
if "`icc'" != "" local post_est `post_est' ("`r(icc)'")



*What follows is taken from pt_base

if "`over_grps'" == "" qui levelsof `over', local(treat_grps)
if "`append_label'" != "" local append_label " `append_label"

local v `varlist'
local var_label "`var_lab'" // storing variable label in local macro
if "`var_lab'" == ""  local var_label:variable label `v'



*auto detecting type of variable (this is very crude)
local type1 = "`type'" // resetting type variable to be that given by 
if "`type1'" == "" {
	pt_pick_type `v'
	local type1 `r(type)'
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
			pt_su_mean_sd `v', over(`over') over_lvl(`i') su_decimal(`su_decimal') brackets(`n_brackets')
			local su_`i' ("`r(sum)'")
		}
		
		*Skew: Median IQR
		if "`type1'" == "skew" {
			di "Treatment group " `i'
			pt_su_median_iqr `v', over(`over') over_lvl(`i') su_decimal(`su_decimal') brackets(`n_brackets')
			local su_`i' ("`r(sum)'")
			local measure1 "median (IQR)"
		}

		*Binary variables
		if "`type1'" == "bin" { // over_lvl = -999999 makes commands summarise whole group
			pt_su_bin `v', over(`over') over_lvl(`i') su_decimal(`su_decimal') `count_only' `per' brackets(`n_brackets') positive(`positive')
			local summaries `summaries' ("`r(sum)'")
			local measure1 "no. (%)"
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


* #Subroutines
*===============================================================================

* ## Summarising variables
*-------------------------------------------------------------------------------
*Determining type
cap prog drop pt_pick_type
prog define pt_pick_type, rclass	
syntax varlist (max=1 numeric)
qui inspect `varlist'
		if r(N_unique) < 3 return local type "bin"
		if r(N_unique) >=3 & r(N_unique) < 10 return local type "cat"
		if r(N_unique) >= 10 | r(N_unique) ==. return local type "cont"
end

*Bin
cap prog drop pt_su_n_per
prog define pt_su_n_per, rclass
	syntax varlist(numeric max = 1), [over(varname) over_lvl(integer -999999) su_decimal(integer 1) brackets(string) count_only per positive(integer 1)]
	if "`per'" != "" local per %
	if `over_lvl' == -999999  qui count if !missing(`varlist')
	if `over_lvl' != -999999 qui count if !missing(`varlist') & `over' == `over_lvl'
	local N = r(N)
	
	if `over_lvl' == -999999 qui count if `varlist'==`positive'
	if `over_lvl' != -999999 qui count if `varlist'==`positive' & `over' == `over_lvl'
	local n = r(N)
	if "`count_only'" == ""{	
		local percent = `n'/`N'*100
		local per_str = string(`percent', "%12.`su_decimal'f")
		local per_str " (`per_str'`per')"
	}	
	return local sum "`n'`per_str'`brackets'" 
end

*Cont
cap prog drop pt_su_mean_sd
prog define pt_su_mean_sd , rclass
syntax varlist(numeric max = 1),  [over(string) over_lvl(integer -999999) su_decimal(integer 1) brackets(string)]
	if `over_lvl' == -999999 su `varlist' 
	if `over_lvl' != -999999 su `varlist' if  `over' == `over_lvl'
	local mean = string(r(mean), "%12.`su_decimal'f")
	local sd = string(r(sd), "%12.`su_decimal'f")
	return local sum "`mean' (`sd')`brackets'"
end

*Skew
cap prog drop pt_su_median_iqr
prog define pt_su_median_iqr, rclass
syntax varlist(numeric max = 1), [over(string) over_lvl(integer -999999) su_decimal(integer 1) brackets(string)]
	if `over_lvl' == -999999 tabstat `varlist', stats(q) save
	if `over_lvl' != -999999 tabstat `varlist' if  `over' == `over_lvl', stats(q) save
	tempname Mstat
	mat define `Mstat' = r(StatTotal) 
	local median = string(`Mstat'[2,1], "%12.`su_decimal'f")
	local q1 = string(`Mstat'[1,1], "%12.`su_decimal'f")
	local q3 = string(`Mstat'[3,1], "%12.`su_decimal'f")
	return local sum "`median' (`q1'-`q3')`brackets'" 
end


* ## Handling estimates
*-------------------------------------------------------------------------------
cap prog drop pt_format_p
prog define pt_format_p, rclass
	if abs(`1') >=0.01 local p = string(`1', "%3.2f")
	if abs(`1') < 0.07 & abs(`1') >=0.001   local p = string(`1', "%4.3f")
	if abs(`1') < 0.01 & abs(`1') >=0.001   local p = string(`1', "%4.3f")
	if abs(`1') < 0.001 & abs(`1') >=0.0001   local p = string(`1', "%5.4f")
	if abs(`1') < 0.0001 local p = "<0.0001"
	return local p "`p'"
end

cap prog drop pt_su_estimates
prog define pt_su_estimates, rclass
syntax varlist(max =1 numeric), [exp decimal(integer 1) icc]

tempname Mresults
mat `Mresults' = r(table)
if "`exp'" != "" {
	local exp1 exp(
	local exp2 )
}
local col_ov = colnumb(`Mresults', "`varlist'")

*Extracting extiamte and confidence interval
foreach r in b ul ll  {
	local row = rownumb(`Mresults',"`r'")
	local `r' = `exp1'`Mresults'[`row',`col_ov']`exp2'
	local `r' = string(``r'', "%12.`decimal'f")
}
return local est "`b' (`ll', `ul')"

*Extracting and formatting p-value
local row_pvalue = rownumb(`Mresults',"pvalue")
local p1 = `Mresults'[`row_pvalue',`col_ov']
pt_format_p `p1'
return local p "`r(p)'"

*Extractig and storing ICC
if "`icc'" != "" {
	estat icc
	pt_format_p r(icc2)
	return local icc "`r(p)'"
}
end

* ## Creating summaries for post file
*-------------------------------------------------------------------------------
cap prog drop pt_post_summaries_create
prog define pt_post_summaries_create, rclass
syntax ,su(string)  [n(string) sum_cols_first order(string)]

if "`order'" == "" local order group_sum
if `"`n'"' == "" return local sum `"`su'"'
else {
	if "`order'" == "group_sum" {
		if "`sum_cols_first'" == "" return local sum `"`n' `su'"'
		if "`sum_cols_first'" != "" return local sum `"`su' `n'"'
	}

	if "`order'" == "group_over" {
		tokenize `n'
		local i = 0
		while `"``++i''"' != "" {
			local n_`i' ``i''
		}
		tokenize `su'
		local i = 0
		while `"``++i''"' != "" {
			if "`sum_cols_first'" == ""  local sum `sum' `n_`i'' ``i''
			if "`sum_cols_first'" != "" local sum `sum' ``i'' `n_`i''
		}
		return local sum `"`sum'"'
	}
}

end

* ## Parsing syntax
*-------------------------------------------------------------------------------

cap prog drop pt_parse_anylist
prog pt_parse_anylist, sclass
	tokenize `"`0'"', parse("(" ")")
	local section = 1
	local section_increase = 0
	local i = 0
	while !inlist(`"``++i''"',"", ",", "if", "in") {
		if `section_increase' == 1 {
			local section = `section' + 1
			local `section_increase' = 0
		}
		local j = `i' + 1
		if "``j''"' == "(" {
			if `"`varlist`section''"' != "" local section = `section' + 1
			local  type`section' ``i''
			local i = `i' + 2
			while `"``++j''"' != ")" {
				local i = `i' + 1
				local varlist`section' `varlist`section'' ``j''
			}
			local section_increase = 1
		}
		else if `"``i''"' != ")" {
			local varlist`section' `varlist`section'' ``i''
		}
	}
	sreturn clear
	forvalues i = 1 (1) `section' {
			sreturn local section`i' `"`varlist`i''"'
			sreturn local type`i' `"`type`i''"'
	}
	sreturn local n_sections = `section'
end

cap prog drop pt_parse_options  // this is supurlefous. Delete
prog pt_parse_options, sclass
	gettoken token 0: 0, bind parse(", ") 
	while !inlist(`"`token'"',"", ",") {
		local anylist `anylist' `token'
		gettoken token 0: 0, bind  parse(", ") 
	}
	sreturn clear
	sreturn local anylist `"`anylist'"'
	sreturn local options `"`0'"'

end

cap prog drop pt_base2
prog pt_base2, rclass
	syntax anything [if] [in] [, Type(string) *]
	di `"`anything'"'
	pt_parse_anylist `anything'
	forvalues i = 1 (1) `s(n_sections)' {
		local section`i' `s(section`i')'
		local type`i' `s(type`i')'
		if "`type'" != "" local type type(`type')
		if "`type`i''" != "" local type type(`type`i'')
		return local pt_base`i' `"`section`i'' `if' `in', `options' `type'"'
	}
	
end
