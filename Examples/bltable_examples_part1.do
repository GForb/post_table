/*
#Instructions
This do file provides two examples using the pt_base

The command pt_base is part of the package post_table. To install post table run the following line:

net install post_table, from("https://raw.githubusercontent.com/GForb/post_table/master")

##Make the following edits to this do file:

1. Edit paths in lines 11 and 12 as required
2. edit line 27 to load your dataset
2. For example 1 update the variable list after the ps_sum command on line 35 to be a list of continuous variables from your data set
3. For example 2 on line 44:
	Update the variable list after the ps_sum command  to be a list of continuous variables from your data set
	Update the name of the variable in the "Over" option from treat to the name of the variable you would like summaries over. This example will not run without an over variable specified.

To view the output of the commands load the data sets saved as ds_example 1 and ds_example 2 and browse using the STATA data browser. 
To obtain datasets in more useful formats either export to excel or run the file data_summary_examples_part2 to create a word document.

*/


cd  "N:\Automating reporting\Example data and results" // set path for where your data is stored and results will be saved

use "eg_data2", clear // load your dataset

********Example 1***********
tempname postname

postfile `postname'  str60 variable  str50 (cat sum)   using bl_example1, replace
count
local N = r(N)
post `postname' ("Baseline Characteristics") ("") ("Randomised (N = `N')")
pt_base age bmi qol gender smoking  alcohol site ethnicity sons daughters, postname(`postname') su_label(append) n_analysis(append cond) cat_col


postclose `postname'




********Example 2***********
*Over treatment group
use "eg_data2", clear // load your dataset

tempname postname

postfile `postname'  str60 variable  str50 (cat sum1 sum2 sum3 sum4 sum5 sum6)   using bl_example2, replace

post `postname' ("Baseline Characteristics") ("") ("Group 0") ("") ("Group 1") ("") ("Overall") ("")
post `postname' ("") ("") ("N") ("Summary") ("N") ("Summary") ("N") ("Summary")
pt_base age bmi qol  gender alcohol smoking site ethnicity sons daughters, postname(`postname') su_label(append) n_analysis(cols) cat_col over(treat) overall(last) order(group_treat)
	

postclose `postname'
use bl_example2, clear 

********Example 3***********
*Over treatment group
use "eg_data2", clear // load your dataset

tempname postname

postfile `postname'  str60 variable  str50 (cat sum1 sum2 sum3 sum4 )   using bl_example2, replace

post `postname' ("Baseline Characteristics") ("") ("Group 0") ("") ("Group 1") ("") 
post `postname' ("") ("") ("N") ("Summary") ("N") ("Summary") 
pt_base age bmi qol  gender alcohol smoking site ethnicity sons daughters, postname(`postname') su_label(append) n_analysis(cols) cat_col over(treat) order(group_treat)
	

postclose `postname'
use bl_example2, clear 


*Viewing output

*Example 1
use bl_example1, clear 	
browse

*Example 2
use bl_example2
browse
