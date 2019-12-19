
capture program drop pt
prog define pt
version 15.1
    pt_parse `0'
end

* #Subroutines
*===============================================================================

* ## Parsing syntax - This is unecessarily complicated but works.
*-------------------------------------------------------------------------------

*Takes the first word after pt and runs command pt_first_word
cap prog drop pt_parse
prog pt_parse
    gettoken subcmd 0: 0
    gettoken cmd 0: 0, parse(",") bind
    local global_options = substr(`"`0'"', 2, .)

    pt_strip_ifin `cmd'
    local main `s(main)'
    local  global_if `s(if)'
    local  global_in `s(in)'
    
    *By this stage the code has taken the original input and split into 4 local macros:
        *main: everything but if, in and options
        *global_options: The options given with original commands
        *global_if and global_in: respective if and in statements
        

    pt_parse_main `main' // this splits main macro into each main section, with options, and any types given
    local n = `s(n_sections)'
    forvalues i = 1 (1) `n'  {
        local main`i' `s(main`i')'
        local options`i' `s(options`i')'
        local type`i' `s(type`i')'
    }
    
    forvalues i = 1 (1) `n' {
        local options `global_options' `options`i''  `type`i')'
        
        *Handling duplicate options
        _parse combop options: options, opsin rightmost option(type) // this command replaces duplicates of option type with the right most instance of the option given 
        
        *Handling if and in 
        local if ""
        local in ""
        if `"`global_if'"' != "" | `"`global_in'"' != "" {
            set trace on
            pt_strip_ifin `main`i''
            local main`i' `s(main)'
            if  `"`global_if'"' != "" {
                if "`s(if)'" == "" local if if `global_if'
                if "`s(if)'" != "" local if if `s(if)' & `global_if'
            }
            if `"`global_in'"' != "" {
                if "`s(in)'" == "" local in in `global_in'
                if "`s(in)'" != "" local if in `s(in)' & `global_in'
            }
        }
        
        
        *Running subcommand
        pt_`subcmd' `main`i'' `if' `in', `options' // running subcommand
    }




end

*Strips if and in from main command and saves in macro
cap prog drop pt_strip_ifin
prog define pt_strip_ifin, sclass
    syntax anything [if/] [in/]
    sreturn clear
    sreturn local main `anything'
    sreturn local if `if'
    sreturn local in `in'
end

cap prog drop pt_parse_main
prog define pt_parse_main, sclass
    local i = 1
    while `"`0'"' != "" {
    local part ""
    local first ""
    gettoken part 0: 0, bind
        gettoken first part : part, parse("(")
        if `"`part'"' == "" {
            local part `"`first'"'
        }
        else if `"`first'"' == "(" {
            local part = substr(`"`part'"', 1, length(`"`part'"') - 1)
        }
        else {
            local type`i' type(`first')
            local part =  substr(`"`part'"', 2, length(`"`part'"') - 2)
        }
        gettoken main`i' options:part , parse(",")
        local options`i' = substr(`"`options'"', 2, .)
        local n = `i++'
    }
    sreturn clear
	forvalues i = 1 (1) `n' {
			sreturn local main`i' `"`main`i''"'
            sreturn local options`i' `"`options`i''"'
			sreturn local type`i' `"`type`i''"'
	}
	sreturn local n_sections = `n'
end


* ## Sub commands
*-------------------------------------------------------------------------------

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

