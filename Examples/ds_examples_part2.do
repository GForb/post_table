/*
#Instructions
This do file creates a word document with the two examples from data_summary_examples part 1.

The table style can be edited in lines 18-48. The will change all tables run.
No edits are required to the do file to run

Remember to close the word document created after any edits

*/

version 15.1

*******************This code section of code can be esited to change the table style***************************
cap prog drop putx_tab
prog  putx_tab
syntax , filename(string) table_no(integer) [title(string) header_rows(integer 1) header_cols(integer 1) width(integer -1)]  
	use  "`filename'", clear
	local b_outside  border(top) border(bottom)
	*Processing width
	if `width' == -1 {
		local layout layout(autofitc)
		local width 
	}
	else {
		local width width(`width'cm)
	}
	
	
	*Table title
	if "`title'" != ""{
		putdocx paragraph, halign(left) 
		putdocx text ("Table `table_no' - `title'"), bold
	}

	*Table
	putdocx table table`table_no' = data(_all) , halign(center)  `layout' `width'   headerrow(`header_rows')
	putdocx table table`table_no'(.,.), font(calibri, 11) // font for table
	qui putdocx describe table`table_no' 
	local n_col =  r(ncols)
	local n_row = r(nrows)
	
	*Formating header rows
	putdocx table table`table_no'(1 (1) `header_rows' ,.), bold valign(center) halign(center) shading(peachpuff )     // font, alignment and shading for header rows can be updated here
	
	
	*Formatting "header columns"
	putdocx table table`table_no'(.,1 (1) `header_cols'), halign(left)  // font and alignment for non header colums can be updated here

	*Formating body of table
	local body_col1 = `header_cols' + 1
	local body_row1 = `header_rows' + 1
	putdocx table table`table_no'(`body_row1' (1) `n_row',`body_col1' (1) `n_col'), halign(right)  // font and alignment for non header colums can be updated here
	

end
**********************************************************************************************************


*Creating word document
cap putdocx clear
putdocx begin, font(calibri, 12)

*Title page
putdocx paragraph, halign(left)
putdocx text ("4. Data summary examples"), bold underline font(calibri, 14) 


*Tables

*Table 1
putx_tab, filename("Examples\Results\ds_example1.dta") table_no(1) title("First example")  width(12)

*Table 2
putx_tab, filename("Examples\Results\ds_example2.dta") table_no(2) title("Second example") header_rows(2) 
putdocx table table2(1,2), colspan(3) halign(center)  // megering cells must be done using putdocx. See help putdocx for more details
putdocx table table2(1,3), colspan(3) halign(center)   // note you must take into account the merge that has already occured when specifying column numbers.
putdocx table table2(1,4), colspan(3) halign(center)    



*Saving document
putdocx save "Examples\Results\ds_examples" , replace
