use Examples/Data/eg_data2.dta, clear

*-------------------------------------------------------------------------------
*pt_process_over
pt_process_over_grps
assert "`s(over_grps)'" == "overall" 

pt_process_over_grps treat
assert "`s(over_grps)'" == "0 1" 

pt_process_over_grps treat, over_grps(1 0)
assert "`s(over_grps)'" == "1 0" 

pt_process_over_grps treat, over_grps(1 0) overall("first")
assert "`s(over_grps)'" == "overall 1 0" 

pt_process_over_grps treat, over_grps(1 0) overall("last")
assert "`s(over_grps)'" == "1 0 overall" 

pt_process_over_grps treat, overall("first")
assert "`s(over_grps)'" == "overall 0 1" 


*-------------------------------------------------------------------------------
*pt_process_var_label
local v age
local var_lab "Hello"
local append_label "World"
pt_process_var_label `v', var_lab(`var_lab') append_label(`append_label')
di "`s(var_label)'"
assert "`s(var_label)'" == "Hello World" 

pt_process_var_label age
di "`s(var_label)'"
assert "`s(var_label)'" == "Age" 

pt_process_var_label age, append_label("(years)")
di "`s(var_label)'"
assert "`s(var_label)'" == "Age (years)" 

pt_process_var_label age, var_lab("Hello")
di "`s(var_label)'"
assert "`s(var_label)'" == "Hello" 

pt_process_var_label age, var_lab("Age at rand.") append_label("(years)")
di "`s(var_label)'"
assert "`s(var_label)'" == "Age at rand. (years)" 

pt_process_var_label treat
di "`s(var_label)'"
assert "`s(var_label)'" == "treat" 

pt_process_var_label treat, append_label("(years)")
di "`s(var_label)'"
assert "`s(var_label)'" == "treat (years)" 


*-------------------------------------------------------------------------------
*pt_process_type_label

pt_process_type_label, type(cont)
di "`s(type_label)'"
assert "`s(type_label)'" == "mean (sd)" 

pt_process_type_label, type(bin)
di "`s(type_label)'"
assert "`s(type_label)'" == "n (%)" 

pt_process_type_label, type(cat)
di "`s(type_label)'"
assert "`s(type_label)'" == "n (%)" 

pt_process_type_label, type(misstable)
di "`s(type_label)'"
assert "`s(type_label)'" == "n (%)" 

pt_process_type_label, type(bin) count_only
di "`s(type_label)'"
assert "`s(type_label)'" == "n" 

pt_process_type_label, type(skew)
di "`s(type_label)'"
assert "`s(type_label)'" == "median (IQR)" 



*-------------------------------------------------------------------------------
*pt_process_missing_non_missing
pt_process_missing_non_missing smoking, ///
	 missing location(cols) show_percent
assert `"`s(miss_non_miss_cols)'"' == `"("100 (10.0)")"' 

pt_process_missing_non_missing smoking if treat ==0, ///
	 missing location(cols) show_percent
assert `"`s(miss_non_miss_cols)'"' == `"("48 (9.7)")"' 

pt_process_missing_non_missing smoking if treat ==1, ///
	 missing location(cols) show_percent
assert `"`s(miss_non_miss_cols)'"' == `"("52 (10.3)")"'


pt_process_missing_non_missing smoking if treat ==0, ///
	missing location(cols) 
assert `"`s(miss_non_miss_cols)'"' == `"("48")"' 

pt_process_missing_non_missing smoking if treat ==1, ///
	location(brackets) show_percent
assert "`s(miss_non_miss_brackets)'" == "[454 (89.7)]" 
assert "`s(brackets_label)'" == "[N (%)]"

pt_process_missing_non_missing smoking, ///
	location(brackets) show_percent per
assert "`s(miss_non_miss_brackets)'" == "[900 (90.0%)]" 
assert "`s(brackets_label)'" == "[N (%)]"

pt_process_missing_non_missing smoking if treat ==0, ///
	location(brackets) show_percent per decimal(0) label(wow)
assert "`s(miss_non_miss_brackets)'" == "[446 (90%)]" 
assert "`s(brackets_label)'" == "[wow]"


pt_process_missing_non_missing smoking if treat ==1, ///
	  location(append)
assert "`s(miss_non_miss_append)'" == "N = 454" 

pt_process_missing_non_missing smoking  , ///
	 location(append) missing
assert "`s(miss_non_miss_append)'" == "missing = 100" 

pt_process_missing_non_missing smoking if treat ==0, ///
  location(append) missing label(wow)
assert "`s(miss_non_miss_append)'" == "wow = 48" 

pt_process_missing_non_missing smoking if treat ==1, ///
	location(brackets) show_percent per decimal(0) cond
assert "`s(miss_non_miss_brackets)'" == "[454 (90%)]"
assert "`s(brackets_label)'" == "[N (%)]"


cap drop cond_missing
gen cond_missing = rnormal(0,1)
replace cond_missing = . if _n <20 & treat ==1
pt_process_missing_non_missing cond_missing if treat ==1, ///
	location(brackets) show_percent per decimal(0) cond
assert "`s(miss_non_miss_brackets)'" == "[495 (98%)]"
assert "`s(brackets_label)'" == "[N (%)]"

