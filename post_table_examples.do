cd "N:\Automating reporting\Example data and results"

*Baseline table not by group
use eg_data2, clear

*Opening postfile
tempname postname

*open postfile with four groups
postfile `postname'  str60 variable  str50 sum   using pt_eg1, replace
count
local N = r(N)
post `postname' ("Baseline Characteristics") ("Summary (N = `N')")
post_table_base age bmi qol smoking gender alcohol site ethnicity, postname(`postname')
post `postname' ("Number of children") ("") // if you would like to add in a header line
post_table_base  sons daughters, postname(`postname')
 
postclose `postname'
use pt_eg1, clear 



*Adding measures and counts to variable labels
use eg_data2, clear
tempname postname

postfile `postname'  str60 variable  str50 sum   using pt_eg2, replace
count
local N = r(N)
post `postname' ("Baseline Characteristics") ("Randomised (N = `N')")
post_table_base age bmi qol smoking gender alcohol site ethnicity, postname(`postname') su_label(append) n_analysis(append)
post `postname' ("Number of children") ("") // if you would like to add in another line
post_table_base  sons daughters, postname(`postname') su_label(append) n_analysis(append)

postclose `postname'
use pt_eg2, clear 


*Specifying summary type. Note putting type cat for a binary variable means that all levels are shown
use eg_data2, clear
tempname postname

postfile `postname'  str60 variable  str50 sum   using pt_eg3, replace
count
local N = r(N)
post `postname' ("Baseline Characteristics") ("Randomised (N = `N')")
post_table_base age bmi qol , postname(`postname') su_label(append) n_analysis(append) type(cont)
post_table_base  gender , postname(`postname') su_label(append) n_analysis(append) type(cat) cat_levels(0 1 2) // the cat_levels option can be used to force summaries of values not in the dataset. Only numeric values can be entered and value labels should be defined for nice reporting.
post_table_base  smoking  alcohol , postname(`postname') su_label(append) n_analysis(append) type(bin) 
post_table_base   ethnicity, postname(`postname') su_label(append) n_analysis(append) type(cat)
post `postname' ("number of children") ("") // if you would like to add in a header line
post_table_base  sons daughters, postname(`postname') su_label(append) n_analysis(append) type(cat)

postclose `postname'
use pt_eg3, clear 
