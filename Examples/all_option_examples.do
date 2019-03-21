/*

This file gives examples demonstraing all the features of pt_base. It is arranged
in the following sections:

	-Section 1: Default table
	-Section 2: By treatment group
	-Section 3: Presenting data
		-Section 3a catagorical variables
	-Section 4: Gaps
	-Section 5: Adding denominators
	-Section 6: Reporting missing data
	-Section 7: Labeling
	
The do file includes /***/ and /**/ before some commands. 
These are Markdoc syntax which are included to allow the code to be reported in a word document with example tables. 
/***/ and /**/  should not be included if copying the code for use.
*/


cd "N:\Automating reporting\Git repository\post_table\Examples\Data and results\All option examples"


*************Programms to open and close post files***************
cap prog drop pt_base_intro
prog define pt_base_intro
	syntax namelist, eg_no(numlist max=1) cols(integer)
	cap log close
	qui log using ptb_eg`eg_no'.smcl, replace nomsg
	use eg_data2, clear
	local results ptb_eg`eg_no'
	tempname postname
	forvalues i = 1 (1) `cols' {
		local post_cols `post_cols' col`i'
	}
	qui postfile `namelist'  str100(`post_cols')   using "`results'.dta", replace
end

cap prog drop  pt_base_close
prog define  pt_base_close 
	syntax namelist, eg_no(numlist max=1)
	postclose `namelist'	
	use "ptb_eg`eg_no'.dta", clear
	format _all %-100s
	qui compress _all
	qui log close
end



********************************************************************************
*                       Section 1: Default table                               *
********************************************************************************


*********************************
local eg_no 1.1
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(2) 

/***
#Section 1
###1.1 Default options
This is the table obtained using default settings with no additional options specified.
***/

/***/ pt_base age gender ethnicity, post(`postname')


/**/ pt_base_close `postname', eg_no(`eg_no')
*********************************




********************************************************************************
*                       Section 2: By treatment group                          *
********************************************************************************
*********************************
local eg_no 2.1
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(3) 

/***
#Section 2
###2.1 Adding `over`
To present data over a variable, for example treatment group, use the option 'over'
***/

/***/ pt_base age gender ethnicity, post(`postname') over(treat) 


/**/ pt_base_close `postname', eg_no(`eg_no')
**********************************


*********************************
local eg_no 2.2
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(4) 

/***
###2.2
The option `over_grps' can be used to specify the order of the treatment groups. 'overall()' can be given with _first_ or _last_. When `over` is specified `overall` summarises the whole dataset, with the position of the overall 
column in the table either first or last.
***/

/***/ pt_base age gender ethnicity, post(`postname') over(treat) overall(first) 


/**/ pt_base_close `postname', eg_no(`eg_no')
*********************************


*********************************
local eg_no 2.3
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(4) 

/***
###2.3
The option over group can be used to change the order of treatment groups.
***/

/***/ pt_base age gender ethnicity, post(`postname') over(treat) over_grps(1 0) overall(last)


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************

********************************************************************************
*                       Section 3: Presenting data                             *
********************************************************************************

*********************************
local eg_no 3.1
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(4) 

/***
###3.1 `type()`
When the option `type` is not specified pt_base decides whether to summarise data as catagorical, binary or continuous based on the number of unique observations. 
Variables with 10 or more unique values will be treated as continuous, and summarised by mean (sd). Variables with 9 or less unique values will be treated as binary or catagorical.

The defaults can be overidden using the type option. The option `type(skew)` can be used to present continuous data as median (IQR). 
For binary variables the default is to consider the value 1 to be positive and to count the number of positives. If you want a different value considered as "positive" use the option `positive(_integer)_`.
Using `type(cat)` for binary variables presents sumaries for both levels of the variable.
***/

/***/ post `postname' ("Summaries") ("") ("") ("") 
/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append)
/***/ pt_base qol , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append)
/***/ pt_base  gender , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)
/***/ pt_base  gender , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append) positive(1)
/***/ pt_base  gender , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat) var_lab(Gender) su_label(append)
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)
/***/ 
/***/ post `postname' ("") ("") ("") ("") 
/***/ post `postname' ("Missing data") ("") ("") ("") 
/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(misstable) su_label(append)
/***/ pt_base qol , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(misstable) su_label(append)
/***/ pt_base  gender , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(misstable)  su_label(append)
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(misstable)  su_label(append)


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 3.2
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(4) 

/***
###3.2 `decimal(#) count_only`
The option `decimal(#)` controls the number of decnimal places. `count_only` suppresses percentages for binary and catagorical variables.
***/


/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) decimal(3)
/***/ pt_base qol , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) decimal(0)
/***/ pt_base  gender , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append) per decimal(2)
/***/ pt_base  gender , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat) var_lab(Gender) su_label(append) count_only 
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append) per 
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append) count_only 


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************

*                       Section 3a: Catagorical variables                      *

*********************************
local eg_no 3.3
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(4) 

/***
##Catagorical variables
###3.3 `cat_levels() cat_tabs`
The option `cat_levels()` orders the levels of catagorical variables. If a value is specified for which there is no data in the dataset a line of zeros is added.
`cat_tabs` can be used to change the indentation of catacorical value labels
***/


label define gender 0 "Male" 1 "Female" 2 "Non-binary" , replace
label values gender gender

/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) 
/***/ pt_base  gender , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat) var_lab(Gender) su_label(append)   cat_levels(0 1 2) cat_tabs(0)
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_tabs(2)


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************



*********************************
local eg_no 3.4
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) 

/***
##Catagorical variables
###3.4 `cat_col`
`cat_col` puts the value label in their own column rather than as indented entries below the variable name. 
When used in conjuction with putdocx and merge this can create a nice looking table.
***/

/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col
/***/ pt_base qol , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col
/***/ pt_base  gender , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat) var_lab(Gender) su_label(append)   cat_col
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col

/***
Note: When using the `cat_col` option, it must be specified for all lines of the table, not just those lines that contain catagorical variables. This is to ensure the correct number of columns is produced.
***/


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************


********************************************************************************
*                               Section 4: Gaps                                *
********************************************************************************


*********************************
local eg_no 4.1
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) 

/***
#Gaps
###4.1 `gap(#) gap_end(#)`
`cat_col` puts the value label in their own column rather than as indented entries below the variable name. 
When used in conjuction with putdocx and merge this can create a nice looking table.
***/

/***/ pt_base age qol , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1)
/***/ pt_base  gender smoking alcohol , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap_end(1)
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(1)


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************


********************************************************************************
*                               Section 5: Denominators                        *
********************************************************************************

*********************************



local eg_no 5.1
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) 

/***
#5. Denominators
The option `n_analysis(_string_)` can be used to include the number of nonmissing observations for each variable. This is used as the denominator when calculating percentages for catagorical or binary variables
and will be the number of observations included when calculating the mean or median. There are three different ways the 'n_analysis()' option can be specified: 'cols', 'append', or 'brackets'.


##Denominators in columns
When `n_analysis'(cols) is specified
###5.1 `n_analysis(cols)` default
When the option cols is specified the default is to place columns containing counts of nonmissing observations in each group before the columns containing the summaries. When denominators or missing data summaries are included in the table the options `miss_decimal(#)` and `su_decimal(#)` can be used to independently control the number of decimal places reported for summary statistics and the percent of missing/nonmissing observations.
***/

/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) n_analysis(cols)  miss_decimal(2) su_decimal(0)
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) n_analysis(cols)  miss_decimal(2) decimal(1)
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) n_analysis(cols) 
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(1) n_analysis(cols) 


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************



*********************************
local eg_no 5.2
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(7) 

/***
###5.2 `n_analysis(cols cond) sum_cols_first
If the option `cond` is added to the `n_analysis()` option then denominaotrs will only be reported for variables with missing data.
***/

/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append)  gap(1) n_analysis(cols cond) sum_cols_first
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append)  gap(1) n_analysis(cols cond) sum_cols_first
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)   gap(1) n_analysis(cols cond)  sum_cols_first
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0)  gap(1) n_analysis(cols cond)  sum_cols_first


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 5.3
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) 

/***
###5.3 `n_analysis(cols cond %) order(group_over)
`order(group_over)` group columns by the over variable first, placing the summary and dednominator columns together. The `%` option wihtin `n_analysis() adds the percent of nonmissing observations. 
The option `per` is specified as well to include a percentage sign.
***/


/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) n_analysis(cols cond %) order(group_over) per 
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) n_analysis(cols  cond %) order(group_over) per 
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) n_analysis(cols cond %)  order(group_over)  per 
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(1) n_analysis(cols cond %)  order(group_over)  per 


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 5.4
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) 

/***
###5.4 `n_analysis(cols cond %) order(group_over)
`order(group_over)` group columns by the over variable first, placing the summary and dednominator columns together. The `%` option wihtin `n_analysis() adds the percent of nonmissing observations. 
The option `per` is specified as well to include a percentage sign.
***/

/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) n_analysis(cols  %) order(group_over) sum_cols_first per 
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) n_analysis(cols  %) order(group_over) sum_cols_first per
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) n_analysis(cols  %)  order(group_over) sum_cols_first per
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(1) n_analysis(cols  %)   order(group_over) sum_cols_first per


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************



*********************************
local eg_no 5.5
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) 

/***
##Denominators as brackets or append
###5.5 `n_analysis(brackets)`, `n_analysis(brackets cond %)`
`n_analysis(brackets)` adds denominators in square brackets. `n_analysis(brackets)` The second half of the table shows that `n_analysis(brackets)` can also be used with the `cond` and `%` options. 
***/

/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) n_analysis(brackets)  
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) n_analysis(brackets) 
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) n_analysis(brackets)  
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(2) n_analysis(brackets)
  
/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) n_analysis(brackets cond %)  
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) n_analysis(brackets cond %) 
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) n_analysis(brackets cond %)  
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(1) n_analysis(brackets cond %)  


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************




*********************************
local eg_no 5.6
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) 

/***
###5.6 `n_analysis(append)`, `n_analysis(append cond %)`
`n_analysis(append)` adds denominators in square brackets. `n_analysis(append)` The second half of the table shows that `n_analysis(append)` can also be used with the `cond` and `%` options. 
***/


/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) n_analysis(append)  
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) n_analysis(append) 
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) n_analysis(append)  
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(2) n_analysis(append)
  
/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) n_analysis(append cond %)  
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) n_analysis(append cond %) 
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) n_analysis(append cond %)  
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(1) n_analysis(append cond %)  


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************









********************************************************************************
*                               Section 6: Missing data                        *
********************************************************************************

local eg_no 6.1
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) 

/***
#6. Missing data
The option `missing(_string_)` can be used to include the number of missing observations for each variable. There are three different ways the 'missing()' option can be specified: 'cols', 'append', or 'brackets'.


##Denominators in columns
When `missing'(cols) is specified
###6.1 `missing(cols)` default
When the option cols is specified the default is to place columns containing counts of missing observations in each group before the columns containing the summaries. When denominators or missing data summaries are included in the table the options `miss_decimal(#)` and `su_decimal(#)` can be used to independently control the number of decimal places reported for summary statistics and the percent of missing/nonmissing observations.
***/

/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) missing(cols)  miss_decimal(2) su_decimal(0)
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) missing(cols)  miss_decimal(2) decimal(1)
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) missing(cols) 
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(1) missing(cols) 


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************



*********************************
local eg_no 6.2
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(7) 

/***
###6.2 `missing(cols cond) sum_cols_first
If the option `cond` is added to the `missing()` option then missing data  will only be reported for variables with missing data.
***/

/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append)  gap(1) missing(cols cond) sum_cols_first
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append)  gap(1) missing(cols cond) sum_cols_first
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)   gap(1) missing(cols cond)  sum_cols_first
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0)  gap(1) missing(cols cond)  sum_cols_first


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 6.3
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) 

/***
###6.3 `missing(cols cond %) order(group_over)
`order(group_over)` group columns by the over variable first, placing the summary and missing data columns together. The `%` option wihtin `missing() adds the percent of missing observations. 
The option `per` is specified as well to include a percentage sign.
***/


/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) missing(cols cond %) order(group_over) per 
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) missing(cols  cond %) order(group_over) per 
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) missing(cols cond %)  order(group_over)  per 
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(1) missing(cols cond %)  order(group_over)  per 


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 6.4
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) 

/***
###6.4 `missing(cols cond %) order(group_over)
`order(group_over)` group columns by the over variable first, placing the summary and dednominator columns together. The `%` option wihtin `missing() adds the percent of missing observations. 
The option `per` is specified as well to include a percentage sign.
***/

/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) missing(cols  %) order(group_over) sum_cols_first per 
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) missing(cols  %) order(group_over) sum_cols_first per
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) missing(cols  %)  order(group_over) sum_cols_first per
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(1) missing(cols  %)   order(group_over) sum_cols_first per


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************



*********************************
local eg_no 6.5
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) 

/***
##Missing data as brackets or append
###6.5 `missing(brackets)`, `missing(brackets cond %)`
`missing(brackets)` adds denominators in square brackets. `missing(brackets)` The second half of the table shows that `missing(brackets)` can also be used with the `cond` and `%` options. 
***/

/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) missing(brackets)  
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) missing(brackets) 
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) missing(brackets)  
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(2) missing(brackets)
  
/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) missing(brackets cond %)  
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) missing(brackets cond %) 
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) missing(brackets cond %)  
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(1) missing(brackets cond %)  


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************




*********************************
local eg_no 6.6
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) 

/***
###5.6 `missing(append)`, `missing(append cond %)`
`missing(append)` adds denominators in square brackets. `missing(append)` The second half of the table shows that `missing(append)` can also be used with the `cond` and `%` options. 
***/


/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) missing(append)  
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) missing(append) 
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) missing(append)  
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(2) missing(append)
  
/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col gap(1) missing(append cond %)  
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col gap(1) missing(append cond %) 
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col gap(1) missing(append cond %)  
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(1) missing(append cond %)  


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************


********************************************************************************
*                               Section 7: Labelling rows                       *
********************************************************************************

local eg_no 7.1
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(3) 

/***
#7 Labelling rows
###7.1 `var_label() append_label(string) su_label(append) su_label_text`
 If the option `su_label()` is not specified no summary label is given with the variable label. `su_label_text()` adds a custom summary label.
 
You can append text to the variable label with the `append_label()` option. The variable label can be completely overidden with the `var_lab()` option.  
***/


/***/ pt_base age , post(`postname') over(treat)  over_grps(1, 0) type(cont)  n_analysis(append) append_label((years))
/***/ pt_base qol, post(`postname') over(treat)   over_grps(1, 0) type(skew)  n_analysis(append)  append_label((higher scores mean better QoL)) 
/***/ pt_base  gender  , post(`postname') over(treat)   over_grps(1, 0) type(bin)    n_analysis(append)   append_label((number of women)) 
/***/ pt_base ethnicity, post(`postname') over(treat)    over_grps(1, 0) type(cat) n_analysis(append)  cat_levels(4 3 2 1 0)  gap(2)  append_label((self reported))
  
/***/ pt_base age , post(`postname') over(treat)   over_grps(1, 0) type(cont)   missing(append cond %)  var_lab(Baseline age) su_label_text(Mean (SD)) su_label(append) 
/***/ pt_base qol, post(`postname') over(treat)    over_grps(1, 0) type(skew)    missing(append cond %) var_lab(SF-36) su_label_text(Median (iqr)) su_label(append)
/***/ pt_base  gender  , post(`postname') over(treat)    over_grps(1, 0) type(bin)   missing(append cond %)   var_lab(Sex) su_label_text(no. (%))  su_label(append) 
/***/ pt_base ethnicity, post(`postname') over(treat)    over_grps(1, 0) type(cat)   cat_levels(4 3 2 1 0)  missing(append cond %)  var_lab(Self report ethnicity) su_label_text(no. (%)) su_label(append)  


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************


local eg_no 7.2
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(4) 

/***
###7.2  `su_label_text su_label(cols)`
The option `su_label(cols)` can be used to report the summary label in its own column
  
***/


/***/ pt_base age , post(`postname') over(treat)  over_grps(1, 0) type(cont)  n_analysis(append) su_label(col)
/***/ pt_base qol, post(`postname') over(treat)   over_grps(1, 0) type(skew)  n_analysis(append)  su_label(col)
/***/ pt_base  gender  , post(`postname') over(treat)   over_grps(1, 0) type(bin)    n_analysis(append)   su_label(col)
/***/ pt_base ethnicity, post(`postname') over(treat)    over_grps(1, 0) type(cat) n_analysis(append)  cat_levels(4 3 2 1 0)  gap(2)   su_label(col)
  
/***/ pt_base age , post(`postname') over(treat)   over_grps(1, 0) type(cont)    missing(append cond %)   su_label_text(Mean (SD)) su_label(col) cat_tabs(0)
/***/ pt_base qol, post(`postname') over(treat)    over_grps(1, 0) type(skew)    missing(append cond %)  su_label_text(Median (iqr)) su_label(col) cat_tabs(0)
/***/ pt_base  gender  , post(`postname') over(treat)    over_grps(1, 0) type(bin)    missing(append cond %)   su_label_text(no. (%)) su_label(col) cat_tabs(0)
/***/ pt_base ethnicity, post(`postname') over(treat)    over_grps(1, 0) type(cat)     cat_levels(4 3 2 1 0)  missing(append cond %)   su_label_text(no. (%)) su_label(col) cat_tabs(0)


/**/ pt_base_close `postname', eg_no(`eg_no')	

*********************************

local eg_no 7.3
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) 

/***
###7.3  su_label(cols)` cat_col

  
***/


/***/ pt_base age , post(`postname') over(treat)  over_grps(1, 0) type(cont)  n_analysis(append) su_label(col) cat_col
/***/ pt_base qol, post(`postname') over(treat)   over_grps(1, 0) type(skew)  n_analysis(append)  su_label(col) cat_col
/***/ pt_base  gender  , post(`postname') over(treat)   over_grps(1, 0) type(bin)    n_analysis(append)   su_label(col) cat_col
/***/ pt_base ethnicity, post(`postname') over(treat)    over_grps(1, 0) type(cat) n_analysis(append)  cat_levels(4 3 2 1 0)  gap(2)   su_label(col) cat_col


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************

********************************************************************************
*                               Section 8: Comments                            *
********************************************************************************

local eg_no 8.1
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) 

/***
###8.1 `comments(add a comment)`, `comment(no_comment)`
A final column of comments can be included using the `comment()' option. If a comment is included for one row in the table, all rows with no comments must have `comment(no comment)' specified.
***/


/***/ pt_base age , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append)  missing(append)  comment(no comment)
/***/ pt_base qol, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append)   missing(append)  comment("QoL measured using SF-36 global")
/***/ pt_base  gender  , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)   gap(1) missing(append)   comment(no comment)
/***/ pt_base ethnicity, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0)   missing(append) comment(Ethnicity not collected at all sites)
   


/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************


********************************************************************************
*                               Section 9: If/In                               *
********************************************************************************

local eg_no 9.1
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) 

/***
###9.1 `if` and `in`
`if` and `in` can be used with pt_base in the usual way for Stata commands.
***/


/***/ pt_base age if ethnicity ==4 , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col  n_analysis(append)  
/***/ pt_base qol if ethnicity ==4, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col  n_analysis(append)  
/***/ pt_base  gender if ethnicity ==4 , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col  n_analysis(append)  
/***/ pt_base ethnicity  if ethnicity ==4, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(2) n_analysis(append)
 
 
/***/ pt_base age in 1/100 , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col  n_analysis(append) 
/***/ pt_base qol in 1/100, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col  n_analysis(append) 
/***/ pt_base  gender in 1/100 , post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col  n_analysis(append) 
/***/ pt_base ethnicity in 1/100, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(2) n_analysis(append) 

/***/ pt_base age in 1/100 if ethnicity ==4 , post(`postname') over(treat)  overall(last) over_grps(1, 0) type(cont) su_label(append) cat_col  n_analysis(append) 
/***/ pt_base qol in 1/100  if ethnicity ==4, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(skew) su_label(append) cat_col  n_analysis(append) 
/***/ pt_base  gender in 1/100  if ethnicity ==4, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(bin)  su_label(append)  cat_col  n_analysis(append) 
/***/ pt_base ethnicity in 1/100  if ethnicity ==4, post(`postname') over(treat)  overall(last)  over_grps(1, 0) type(cat)  su_label(append)   cat_levels(4 3 2 1 0) cat_col gap(2) n_analysis(append) 

/**/ pt_base_close `postname', eg_no(`eg_no')	
*********************************



/*
	[ ///
	Type(string) /// options: skew (reports median IQR), bin (no %), cont (mean sd), cat (freq by group)
	count_only /// suppresses percentages reported with binary and catagorical variables
	over(varname) /// specify name for over variable 
	over_grps(numlist) /// specify the values the "over" variable can take and which order they should appear. If over is not specified command produces one summary
	overall(string) /// include a summary column for all observations in addition to those by over group. Can be given as first or last. if first column appears first, if last last obv.
	cat_levels(numlist) /// if variable catagorical levels allows catogories to be customised
	cat_col /// if cat col is specified catagories for catagorical variables are included in a seperate column. For other variable types an extra collumn is added 
	gap(integer 0) /// adds empty rows to baseline table after each variable
	gap_end(integer 0)  /// adds empty rows to baseline table after all variables
	decimal(integer 1) miss_decimal(integer 1) su_decimal(integer 1) /// specify number of decimal places to be used 
	positive(integer 1) /// specifies what a positive is for binary variables, default is 1
	Missing(string)  /// specifies that missing data is to be reported, options are cols, brackets. 
	order(string) /// options group_sum or group_over. Groups colmns by summary ie. missing data columns then summary columns or groups columns by treatment group.
	su_label(string) /// su_label has can be append or col. If append is specified adds descrptor for the summary measure to variable label. If col is specified adds descriptor in separate column.
	su_label_test(string) /// Overides default summary labels
	append_label(string) /// appends extra text to variable and summary label
	var_lab(string) /// Overides default variable label
	per /// displays "%" sign in table alongside frequencies
	comment(string) /// adds column to end of table with text contained in string
	]
