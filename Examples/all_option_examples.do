*This file gives examples demonstraing all the features of pt_base
cd "N:\Automating reporting\Example data and results\pt_base all examples"

cap prog drop pt_base_intro
prog define pt_base_intro
	syntax namelist, eg_no(integer) cols(integer)
	cap log close
	log using ptb_eg`eg_no', replace
	use eg_data2, clear
	local results ptb_eg`eg_no'
	tempname postname
	forvalues i = 1 (1) `cols' {
		local post_cols `post_cols' col`i'
	}
	postfile `namelist'  str100(`post_cols')   using `results', replace
end

cap prog drop pt_base_close
prog define pt_base_close 
	syntax namelist, eg_no(integer)
	postclose `namelist'	
	use ptb_eg`eg_no', clear
	format _all %-100s
	qui compress _all
	qui log close
end


**********Section 1***********

*********************************
local eg_no 1
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(2) // openening post file, see function at top of do file for detail

pt_base age gender ethnicity, post(`postname')

pt_base_close `postname', eg_no(`eg_no')
*********************************



*********************************
local eg_no 2
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(3) // openening post file, see function at top of do file for detail

pt_base age gender ethnicity, post(`postname') over(treat)  gap(1) gap_end(2)

pt_base_close `postname', eg_no(`eg_no')
**********************************


*********************************
local eg_no 3
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(4) // openening post file, see function at top of do file for detail

pt_base age gender ethnicity, post(`postname') over(treat) overall(first) 

pt_base_close `postname', eg_no(`eg_no')
*********************************


*********************************
local eg_no 4
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(4) // openening post file, see function at top of do file for detail

pt_base age gender ethnicity, post(`postname') over(treat)  overall(last)

pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 5
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(4) // openening post file, see function at top of do file for detail

pt_base age gender ethnicity, post(`postname') over(treat)  overall(last) su_label(append)

pt_base_close `postname', eg_no(`eg_no')
*********************************


*********************************
local eg_no 6
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) // openening post file, see function at top of do file for detail

pt_base age gender ethnicity, post(`postname') over(treat)  overall(last) su_label(col)

pt_base_close `postname', eg_no(`eg_no')
*********************************


*********************************
local eg_no 7
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) // openening post file, see function at top of do file for detail

pt_base age gender ethnicity, post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0)

pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 8
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cont) append_label("(years)")
pt_base age , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(skew) append_label("(years)")
pt_base  gender , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(bin)
pt_base  gender , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2)
pt_base ethnicity, post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cat) cat_tabs(2)	

pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 9
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cont) append_label("(years)")
pt_base age , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(skew) append_label("(years)")
pt_base  gender , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(bin) per
pt_base  gender , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per
pt_base ethnicity, post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cat) cat_tabs(2)	 per

pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 10
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cont) append_label("(years)")
pt_base age , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(skew) append_label("(years)")
pt_base  gender , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(bin) per count_only
pt_base  gender , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per count_only
pt_base ethnicity, post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cat) cat_tabs(2)	 per count_only

pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 11
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(6) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cont) append_label("(years)") cat_col gap(1)
pt_base age , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(skew) append_label("(years)") cat_col gap_end(1)
pt_base  gender , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(bin) per count_only cat_col
pt_base  gender , post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per count_only cat_col
pt_base ethnicity, post(`postname') over(treat)  overall(last) su_label(col) over_grps(1, 0) type(cat) cat_tabs(2)	 per count_only cat_col

pt_base_close `postname', eg_no(`eg_no')	
*********************************





*********************************
local eg_no 12
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(last) su_label(append) over_grps(1, 0) type(cont) append_label("(years)") cat_col gap(1) decimal(0)
pt_base age , post(`postname') over(treat)  overall(last) su_label(append) over_grps(1, 0) type(skew) append_label("(years)") cat_col gap_end(1) decimal(0)
pt_base  gender , post(`postname') over(treat)  overall(last) su_label(append) over_grps(1, 0) type(bin) per  cat_col decimal(0)
pt_base  gender , post(`postname') over(treat)  overall(last) su_label(append) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per  cat_col decimal(0)
pt_base ethnicity, post(`postname') over(treat)  overall(last) su_label(append) over_grps(1, 0) type(cat) cat_tabs(2)	 per  cat_col decimal(0)

pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 13
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(5) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cont) append_label("(years)") cat_col gap(1) decimal(0)
pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(skew) append_label("(years)") cat_col gap_end(1) decimal(0)
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(bin) per  cat_col decimal(0)
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per  cat_col decimal(0)
pt_base ethnicity, post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) cat_tabs(2)	 per  cat_col decimal(0)

pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
	local eg_no 14
	tempname postname
	pt_base_intro `postname', eg_no(`eg_no') cols(4) // openening post file, see function at top of do file for detail

	pt_base age qol gender smoking  ethnicity , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(misstable)   gap(1) decimal(2) per

	pt_base_close `postname', eg_no(`eg_no')	
*********************************


**************Including denominators***************************


*********************************
local eg_no 15
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cont) append_label("(years)") cat_col gap(1) decimal(0) n_analysis(cols) 
pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(skew) append_label("(years)") cat_col gap_end(1) decimal(0) n_analysis(cols)
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(bin) per  cat_col decimal(0) n_analysis(cols) gap_end(1)
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per  cat_col decimal(0) n_analysis(cols)  gap_end(1)
pt_base ethnicity, post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) cat_tabs(2)	 per  cat_col decimal(0)  n_analysis(cols)  gap_end(1)

pt_base_close `postname', eg_no(`eg_no')	
*********************************

*********************************
local eg_no 16
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cont) append_label("(years)") cat_col gap(1) decimal(0) n_analysis(cols) sum_cols_first
pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(skew) append_label("(years)") cat_col gap_end(1) decimal(0) n_analysis(cols) sum_cols_first
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(bin) per  cat_col decimal(0) n_analysis(cols) gap_end(1) sum_cols_first
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per  cat_col decimal(0) n_analysis(cols)  gap_end(1) sum_cols_first
pt_base ethnicity, post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) cat_tabs(2)	 per  cat_col decimal(0)  n_analysis(cols)  gap_end(1) sum_cols_first

pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 17
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cont) append_label("(years)") cat_col gap(1) decimal(0) n_analysis(cols) order(group_treat) 
pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(skew) append_label("(years)") cat_col gap_end(1) decimal(0) n_analysis(cols) order(group_treat)
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(bin) per  cat_col decimal(0) n_analysis(cols) gap_end(1) order(group_treat)
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per  cat_col decimal(0) n_analysis(cols)  gap_end(1) order(group_treat)
pt_base ethnicity, post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) cat_tabs(2)	 per  cat_col decimal(0)  n_analysis(cols)  gap_end(1) order(group_treat)

pt_base_close `postname', eg_no(`eg_no')	
*********************************


**************Including missing data***************************


*********************************
local eg_no 18
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cont) append_label("(years)") cat_col gap(1) decimal(0) missing(cols) 
pt_base qol , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(skew) append_label("(years)") cat_col gap_end(1) decimal(0) missing(cols)
pt_base  smoking , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(bin) per  cat_col decimal(0) missing(cols) gap_end(1)
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per  cat_col decimal(0) missing(cols)  gap_end(1)
pt_base ethnicity, post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) cat_tabs(2)	 per  cat_col decimal(0)  missing(cols)  gap_end(1)

pt_base_close `postname', eg_no(`eg_no')	
*********************************

*********************************
local eg_no 19
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cont) append_label("(years)") cat_col gap(1) decimal(0) missing(cols) sum_cols_first
pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(skew) append_label("(years)") cat_col gap_end(1) decimal(0) missing(cols) sum_cols_first
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(bin) per  cat_col decimal(0) missing(cols) gap_end(1) sum_cols_first
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per  cat_col decimal(0) missing(cols)  gap_end(1) sum_cols_first
pt_base ethnicity, post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) cat_tabs(2)	 per  cat_col decimal(0)  missing(cols)  gap_end(1) sum_cols_first

pt_base_close `postname', eg_no(`eg_no')	
*********************************


*********************************
local eg_no 20
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cont) append_label("(years)") cat_col gap(1) decimal(0) missing(cols) order(group_treat) 
pt_base qol , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(skew) append_label("(years)") cat_col gap_end(1) decimal(0) missing(cols) order(group_treat)
pt_base  smoking , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(bin) per  cat_col decimal(0) missing(cols) gap_end(1) order(group_treat)
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per  cat_col decimal(0) missing(cols)  gap_end(1) order(group_treat)
pt_base ethnicity, post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) cat_tabs(2)	 per  cat_col decimal(0)  missing(cols)  gap_end(1) order(group_treat)

pt_base_close `postname', eg_no(`eg_no')	
*********************************



*********************************
local eg_no 20
tempname postname
pt_base_intro `postname', eg_no(`eg_no') cols(8) // openening post file, see function at top of do file for detail

pt_base age , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cont) append_label("(years)") cat_col gap(1) decimal(0) missing(cols %) order(group_treat) per
pt_base qol , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(skew) append_label("(years)") cat_col gap_end(1) decimal(0) missing(cols %) order(group_treat) per
pt_base  smoking , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(bin) per  cat_col decimal(0) missing(cols %) gap_end(1) order(group_treat)
pt_base  gender , post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) var_lab(Gender) cat_tabs(2) per  cat_col decimal(0) missing(cols %)  gap_end(1) order(group_treat)
pt_base ethnicity, post(`postname') over(treat)  overall(first) su_label(append) over_grps(1, 0) type(cat) cat_tabs(2)	 per  cat_col decimal(0)  missing(cols %)  gap_end(1) order(group_treat)

pt_base_close `postname', eg_no(`eg_no')	
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
	missing(string) /// Specifies that the numbers with complete data should be reported, options cols, brackets, or append
	order(string) /// options group_sum or group_treat. Groups colmns by summary ie. missing data columns then summary columns or groups columns by treatment group.
	su_label(string) /// su_label has can be append or col. If append is specified adds descrptor for the summary measure to variable label. If col is specified adds descriptor in separate column.
	su_label_text(string) /// Overides default summary labels
	append_label(string) /// appends extra text to variable and summary label
	var_lab(string) /// Overides default variable label
	per /// displays "%" sign in table alongside frequencies
	comment(string) /// adds column to end of table with text contained in string
	]



**********Section 2***********
*missing data




**********Section 3***********
*missing data
