
capture program drop pt
prog define pt
version 15.1
    gettoken subcmd 0: 0
    pt_parse `0' // sreturn command which process parts of command, if, in and options into separate commands.
    forvalues i = 1 (1) `s(n)' {
        pt_`subcmd' `s(command`i')'
    }
    
end

* #Subroutines
*===============================================================================

* ## Parsing syntax - This is unecessarily complicated but works.
*-------------------------------------------------------------------------------

*Takes the first word after pt and runs command pt_first_word
cap prog drop pt_parse
prog pt_parse, sclass
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
        local options`i' `global_options' `options`i''  `type`i')'
        
        *Handling duplicate options
        _parse combop options`i': options`i', opsin rightmost option(type) // this command replaces duplicates of option type with the right most instance of the option given 
        
        *Handling if and in 
        if `"`global_if'"' != "" | `"`global_in'"' != "" {
            pt_strip_ifin `main`i''
            local main`i' `s(main)'
            if  `"`global_if'"' != "" {
                if "`s(if)'" == "" local if`i' `global_if'
                if "`s(if)'" != "" local if`i' "`s(if)'"
            }
            if `"`global_in'"' != "" {
                if "`s(in)'" == "" local in`i' in `global_in'
                if "`s(in)'" != "" local in`i' "`s(in)'"
            }
        }
    }
        
        *Returning values
    sreturn clear
    sreturn local n `n'
    forvalues i = 1 (1) `n' {
        sreturn local command`i' `"`main`i'' `if`i'' `in`i'', `options`i''"'
     }
    



    
end

*Strips if and in from main command and saves in macro
cap prog drop pt_strip_ifin
prog define pt_strip_ifin, sclass
    syntax anything [if] [in]
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

/*
cap prog drop pt_base
prog pt_base



end
*/



* ## Subroutines for summarising variables
*-------------------------------------------------------------------------------
*Processing over option
cap prog drop pt_process_over_grps
prog define pt_process_over_grps, sclass
syntax [varname(default=none)], [over_grps(numlist) overall(string)]
	if "`varlist'" != "" {
		if "`over_grps'" == ""  qui levelsof `varlist', local(over_grps)
		if "`overall'" == "first" local over_grps overall `over_grps'
		if "`overall'" == "last" local over_grps  `over_grps' overall
	}
	if "`varlist'" == "" local over_grps overall
	sreturn clear
	sreturn local over_grps "`over_grps'"
end



*Determining type
cap prog drop pt_pick_type
prog define pt_pick_type, sclass	
syntax varlist (max=1 numeric), [max_unique_cat(integer 9)]
sreturn clear
qui inspect `varlist'
		if r(N_unique) < 3 {
			sreturn local type "bin"
		}
		else if r(N_unique) <= `max_unique_cat' {
			sreturn local type "cat"
		}
		else {
			sreturn local type "cont"
		}
end

*Processing Variable name
cap prog drop pt_process_var_label
prog define pt_process_var_label, sclass
syntax varname, [var_lab(string) append_label(string)]
sreturn clear
	local var_label `var_lab' 
	if `"`var_lab'"' == "" local var_label:variable label `varlist'
	if `"`var_label'"' == "" local var_label = "`varlist'"
	local var_label `var_label' `append_label' // adding user specified append to
	sreturn local var_label `var_label'
end

*Creating summary laels for different types
cap prog drop pt_process_type_label
prog define pt_process_type_label, sclass
syntax, type(string) [count_only]
sreturn clear
	if "`type'" == "cont" local measure "mean (sd)"
	if "`type'" == "bin" | "`type'" == "cat" | "`type'" == "misstable" {
		local measure "n (%)"
		if "`count_only'" != "" local measure "n"
	}
	if "`type'" == "skew"  local measure "median (IQR)"
	sreturn local type_label "`measure'"
end

cap prog drop pt_process_missing_non_missing
prog define pt_process_missing_non_missing, sclass
syntax varname [if/], /// 
   location(string) /// 
	[decimal(passthru) per show_percent cond label(string) missing]
	sreturn clear

	if "`if'" != "" {
		local if_if if `if'
		local and & `if'
	}
	if "`location'" == "append" local if

	local count_only
	if "`show_percent'" == "" local count_only count_only
	
	if "`show_percent'" != "" local per_lab " (%)"
	if "`label'" == "" {
		if "`missing'" != "" {
			local label "missing`per_lab'"
		}
		else {
			local label "N`per_lab'"
		}
	}
	
	*location must be one of brackets, append or cols
	if !strpos("brackets append cols", "`location'") {
		di as error "location must be one of brackets, append or cols"	
	}
	if "`cond'" !=  "" {
		qui count if missing(`varlist') `and'
		if r(N) == 0 exit
	}
	
	*Calculating summaries
	pt_count_missing_non_missing `varlist' `if_if', ///
		`missing'  `decimal' `per' `count_only'
	local sum `s(sum)'
	
	*Returning values
	sreturn clear
	if "`location'" == "cols" {
		sreturn local miss_non_miss_cols `"("`sum'")"'
	}
	if "`location'"  == "brackets" {
		sreturn local miss_non_miss_brackets "[`sum']"
		sreturn local brackets_label "[`label']"
	}
	if "`location'" == "append" {
		sreturn local miss_non_miss_append "`label' = `sum'"
	}
	
end
* ## N and missing data
*-------------------------------------------------------------------------------
*Summaries and counting missing data
*Bin
cap prog drop pt_summarise_bin
prog define pt_summarise_bin, sclass
syntax varname [if/], ///
	[per decimal(integer 1) count_only positive(integer 1) brackets(string) *]
	if "`if'" != "" local if & `if'
	if "`per'" != "" local per %
	qui count if !missing(`varlist')  `if'
	local N = r(N)
	qui count if `varlist' == `positive' `if'
	local n = r(N)
	if "`count_only'" == ""{	
		local percent = `n'/`N'*100
		local per_str = string(`percent', "%12.`decimal'f")
		local per_str " (`per_str'`per')"
	}
	sreturn local sum "`n'`per_str'`brackets'"
end

cap prog drop pt_count_missing_non_missing
prog pt_count_missing_non_missing, sclass
syntax varname [if],  [per count_only missing decimal(passthru)] 
	sreturn clear
	local positive = "`missing'" != ""
	tempvar miss_flag
	gen `miss_flag' = missing(`varlist')
	pt_summarise_bin `miss_flag' `if', `per' `decimal' `count_only' positive(`positive')
	sreturn local sum `"`s(sum)'"'
end

cap prog drop pt_summarise_misstable
prog define pt_summarise_misstable, sclass
syntax varlist(numeric max = 1) [if],  [per count_only decimal(passthru) *] 
	sreturn clear
	pt_count_missing_non_missing `varlist' `if', /// 
		missing `per' `count_only'  `decimal'
	sreturn local sum `"`s(sum)'"' 
end


*Cont
cap prog drop pt_summarise_cont
prog define pt_summarise_cont , sclass
syntax varlist(numeric max = 1) [if],  [decimal(integer 1) brackets(string) *]
	su `varlist' `if'
	local mean = string(r(mean), "%12.`decimal'f")
	local sd = string(r(sd), "%12.`decimal'f")
	sreturn clear
	sreturn local sum "`mean' (`sd')`brackets'"
end

*Skew
cap prog drop pt_summarise_skew
prog define pt_summarise_skew, sclass
syntax varlist(numeric max = 1) [if],  [decimal(integer 1) brackets(string) *]
	tabstat `varlist' `if', stats(q) save
	tempname Mstat
	mat define `Mstat' = r(StatTotal) 
	local median = string(`Mstat'[2,1], "%12.`decimal'f")
	local q1 = string(`Mstat'[1,1], "%12.`decimal'f")
	local q3 = string(`Mstat'[3,1], "%12.`decimal'f")
	sreturn clear
	sreturn local sum "`median' (`q1'-`q3')`brackets'" 
end



*cat
cap prog drop pt_summarise_cat
prog define pt_summarise_cat, sclass
	syntax varlist(numeric max = 1) `if', ///
	[per decimal(integer 1) count_only cat_cols brackets(string) *]

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

