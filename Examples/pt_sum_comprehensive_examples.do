/*

This file gives examples demonstraing all the features of pt_sum. It is arranged
in the following sections:
	
The do file includes /***/ and /**/ before some commands. 
These are Markdoc syntax which are included to allow the code to be reported in a word document with example tables. 
/***/ and /**/  should not be included if copying the code for use.
*/

*************Programms to open and close post files***************
cap prog drop pt_sum_intro
prog define pt_sum_intro
local dir "N:\Automating reporting\Git repository\post_table\Examples\Data and results\All option examples"
	syntax namelist, eg_no(numlist max=1) cols(integer)
	cap log close
	qui log using pts_eg`eg_no'.smcl, replace nomsg
	use "`dir'\eg_data2", clear
	local results pts_eg`eg_no'
	tempname postname
	forvalues i = 1 (1) `cols' {
		local post_cols `post_cols' col`i'
	}
	qui postfile `namelist'  str100(`post_cols')   using "`dir'\\`results'.dta", replace
end

cap prog drop  pt_sum_close
prog define  pt_sum_close 
local dir "N:\Automating reporting\Git repository\post_table\Examples\Data and results\All option examples"
	syntax namelist, eg_no(numlist max=1)
	postclose `namelist'	
	use "`dir'\\pts_eg`eg_no'.dta", clear
	format _all %-100s
	qui compress _all
	qui save "N:\Automating reporting\Git repository\post_table\Testing\pt_sum\Test data\pts_eg`eg_no'.dta", replace
	qui log close
end








********************************************************************************
*                       Section 0: Default table                               *
********************************************************************************


*********************************
local eg_no 1
tempname postname
pt_sum_intro `postname', eg_no(`eg_no') cols(5) 

/***

###1 Default options
Ther are four statistics available with pts_sum. Statistics can be arranged in any order. Options `gap()` and `gap_end()` can be used to add gaps between rows.
***/

/***/ post `postname' ("") ("N") ("Mean (sd)") ("Median (IQR)") ("Range")
/***/ pt_sum age qol bmi  , postname(`postname') stats(N mean_sd median_iqr range) gap_end(1)

/***/ post `postname' ("") ("N")   ("Range") ("Median (IQR)") ("Mean (sd)")
/***/ pt_sum age qol bmi  , postname(`postname') stats(N range  median_iqr mean_sd)


/**/ pt_sum_close `postname', eg_no(`eg_no')
*********************************


local eg_no 2
tempname postname
pt_sum_intro `postname', eg_no(`eg_no') cols(5) 


/***
###2 `over()`
The option `over()` can be used to present statsitics over another variable, for example treatment group. `over_grps` can be used to set the order in which the groups appear in.
 `order(group_sum)` groups the columns by treatment group then by summary statistic.
***/

/***/ post `postname' ("") ("Group 0") ("") ("Group 1") ("") 
/***/ post `postname' ("")  ("Mean (sd)")  ("Median (IQR)")  ("Mean (sd)")  ("Median (IQR)")
/***/ pt_sum age qol bmi  , postname(`postname') stats(mean_sd  median_iqr) gap_end(1) over(treat)

/***
Statistics can be arranged in any order
***/

/***/ post `postname' ("") ("Group 1") ("") ("Group 0") ("")   
/***/ post `postname' ("") ("N")  ("Range")  ("N")  ("Range") 
/***/ pt_sum age qol bmi  , postname(`postname') stats(N range ) over(treat) over_grps(1 0) gap_end(1)


/***
Summaries can be grouped by `over` group or by statistic type.
***/

/***/ post `postname' ("") ("Mean (sd)") ("") ("Median (IQR)") ("")   
/***/ post `postname' ("") ("Group 1")  ("Group 0")  ("Group 1")  ("Group 0") 
/***/ pt_sum age qol bmi  , postname(`postname') stats(mean_sd median_iqr) over(treat) over_grps(1 0)  order(group_sum)



/**/ pt_sum_close `postname', eg_no(`eg_no')
*********************************




local eg_no 3
tempname postname
pt_sum_intro `postname', eg_no(`eg_no') cols(7) 


/***
###3 `overall()`
When `over()` is specified, `overall()` can be used to a column summarising the wholde dataset. `overall(first)` positions the overall column first, `overall(last)` positions the column last.
***/

/***/ post `postname' ("") ("Group 0") ("") ("Group 1") ("")  ("Overall") ("") 
/***/ post `postname' ("")  ("Mean (sd)")  ("Median (IQR)")  ("Mean (sd)")  ("Median (IQR)") ("Mean (sd)")  ("Median (IQR)")
/***/ pt_sum age qol bmi  , postname(`postname') stats(mean_sd  median_iqr) gap_end(1) over(treat) overall(first)


/***
Summaries can be grouped by `over` group or by `statistic type.
***/

/***/ post `postname' ("") ("N") ("") ("")  ("Range") ("")    ("") 
/***/ post `postname' ("") ("Group 1")  ("Group 0")  ("Overall")  ("Group 1")  ("Group 0")    ("Overall")
/***/ pt_sum age bmi qol , postname(`postname') stats(N range ) over(treat) over_grps(1 0) gap_end(1) overall(last) order(group_sum)


/**/ pt_sum_close `postname', eg_no(`eg_no')
*********************************


local eg_no 4
tempname postname
pt_sum_intro `postname', eg_no(`eg_no') cols(6) 


/***
###4 Decimals, variable names and comments.
`decimal(#)`, `range_decimal(#)` and `med_iqr_decimal(#)` set the number of decimal places to be used (default is 1). `comment()` can be used to add a comment. 
`var_lab` and `append_label` can be used to append text to variable labels.
***/


/***/ post `postname' ("") ("N") ("Mean (sd)") ("Median (IQR)") ("Range") ("Comment") 
/***/ pt_sum age  , postname(`postname') stats(N mean_sd median_iqr range)  var_lab("Custom variable name") comment("The decimal option sets the decimal places") decimal(0) 
/***/ pt_sum  bmi  , postname(`postname') stats(N mean_sd median_iqr range) append_label("- you can add extra text") comment("no comment") 
/***/ pt_sum  qol , postname(`postname') stats(N mean_sd median_iqr range)  comment("You can have different numbers of d.p. for different summaries") decimal(2) range_decimal(0) med_iqr_decimal(1)



/**/ pt_sum_close `postname', eg_no(`eg_no')
*********************************


local eg_no 5
tempname postname
pt_sum_intro `postname', eg_no(`eg_no') cols(5) 


/***
###5 `if` and `in`
`if` and `in` can be used in the normal way
***/


/***/ post `postname' ("") ("N") ("Mean (sd)") ("Median (IQR)") ("Range")
/***/ pt_sum age if age > 40 , postname(`postname') stats(N mean_sd median_iqr range)
/***/ pt_sum  bmi if bmi in 1/10  , postname(`postname') stats(N mean_sd median_iqr range)
/***/ pt_sum  qol in 1/10 if qol > 50 , postname(`postname') stats(N mean_sd median_iqr range)  



/**/ pt_sum_close `postname', eg_no(`eg_no')
*********************************
