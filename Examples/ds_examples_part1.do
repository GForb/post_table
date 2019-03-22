/*
#Instructions
This do file provides two examples using the ps_sum command. The first example summarises all the data, the second example provides a summary by treatment group with an overall column.

The command pt_sum is part of the package post_table. To install post table run the following line:

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


cd  "N:\Automating reporting\Git repository\post_table\Examples\Data and results" // set path for where your data is stored and results will be saved

use "eg_data2", clear // load your dataset

********Example 1***********
*Continuous variables using pt_sum
tempname postname
postfile `postname'  str60 variable str20(sum1 sum2 sum3) using ds_example1, replace // open postfile with the required number of columns, variables must be strings, names are not important

post `postname' ("Variable") ("N") ("mean (sd)") ("Range")  // post a row of headers
pt_sum age bmi qol, postname(`postname') stats(N mean_sd  range) // replace age bmi and qol on this line with a list of continuous variables from your dataset
postclose `postname'


********Example 1***********
*Over treatment groups
tempname postname
postfile `postname'  str60 variable str20(sum1 sum2 sum3 sum4 sum5 sum6 sum7 sum8 sum9) using ds_example2, replace // open postfile with the required number of columns, variables must be strings, names are not important

post `postname' ("") ("Overall") ("") ("") ("Group1") ("") ("")  ("Group2") ("") ("")  // post any rows of headers you would like
post `postname' ("Variable") ("N") ("mean (sd)") ("Range") ("N") ("mean (sd)") ("Range")  ("N") ("mean (sd)") ("Range") // post some more headers
pt_sum age bmi qol, postname(`postname') stats(N mean_sd range) over(treat) overall(first)  // replace age bmi and qol on this line with a list of continuous variables from your dataset
postclose `postname'



*Viewing output

*Example 1
use ds_example1, clear
browse

*Example 2
use ds_example2 
browse
