/*
#Instructions
This do file creates a word document with the two examples from data_summary_examples part 1.

The table style can be edited in lines 18-48. The will change all tables run.
No edits are required to the do file to run

Remember to close the word document created if running this file again

To run table 3, an excel named 

*/


cd  "N:\Automating reporting\Git repository\post_table\Examples\Data and results" // set path for where your data is stored and results will be saved



*******************This code section of code can be esited to change the table style***************************
cap prog drop putx_tab
prog  putx_tab
syntax , filename(string) table_no(integer) [title(string) header_rows(integer 1) header_cols(integer 1) width(integer -1)]  
	use  "`filename'", clear
	local b_outside  border(top) border(bottom)
	*Processing width
	if `width' == -1 {
		local layout layout(autofitw)
		local width 
	}
	else {
		local width width(`width'cm)
	}
	local layout layout(autofitc)
	
	*Table title
	if "`title'" != ""{
		putdocx paragraph, halign(left) 
		putdocx text ("Table `table_no' - `title'"), bold
	}

	*Table
	putdocx table table`table_no' = data(_all) , halign(center)  `layout' `width' cellmargin(top, 1pt)   headerrow(`header_rows')
	putdocx table table`table_no'(.,.), font(calibri, 11) // font for table
	qui putdocx describe table`table_no' 
	local n_col =  r(ncols)
	local n_row = r(nrows)
	
	*Formating header rows
	putdocx table table`table_no'(1 (1) `header_rows' ,.), bold valign(center) halign(center) shading(papayawhip)     // font, alignment and shading for header rows can be updated here
	
	
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

*title
putdocx pagebreak
putdocx paragraph, halign(left)
putdocx text ("5. Baseline table examples"), bold underline font(calibri, 12)  


*Tables

*Table 1
putx_tab, filename("bl_example1.dta") table_no(1) title("First example")  width(12)
*Merging cells
forvalues i = 1 (1) 7 {
	putdocx table table1(`i',1), colspan(2)
}
putdocx table table1(8,1), rowspan(3)
putdocx table table1(11,1), rowspan(5)
putdocx table table1(16,1), rowspan(4)
putdocx table table1(20,1), rowspan(4)

putdocx pagebreak

*Table 2

putx_tab, filename("bl_example2.dta") table_no(2) title("Second example") header_rows(2) 
putdocx table table2(1,3), colspan(2) halign(center)  // megering cells must be done using putdocx. See help putdocx for more details
putdocx table table2(1,4), colspan(2) halign(center)   // note you must take into account the merge that has already occured when specifying column numbers.
  
forvalues i = 1 (1) 8 {
	putdocx table table2(`i',1), colspan(2)
}
putdocx table table2(9,1), rowspan(3)
putdocx table table2(12,1), rowspan(5)
putdocx table table2(17,1), rowspan(4)
putdocx table table2(21,1), rowspan(4)


*Table from excel
putdocx pagebreak
import excel using example_excel, clear
save excel_example, replace
putx_tab, filename("excel_example.dta") table_no(3) title("Some data from a spreadsheet") 
*Editing the alignment from default 
putdocx table table3(.,.), halign(left) 

putdocx pagebreak


*Saving document
putdocx save "bl_examples" , replace
