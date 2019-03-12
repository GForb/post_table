cd "N:\Automating reporting\Example data and results"


cap prog drop putx_tab


prog  putx_tab
syntax , filename(string) table_no(integer) [title(string) width(integer -1)]  // add some options ie. width, number of header rows.
	use  "`filename'", clear
	local b_outside  border(top) border(bottom)
	*Table title
	if "`title'" != ""{
		putdocx paragraph, halign(left) 
		putdocx text ("Table `table_no' - `title'"), bold
	}
	
	*Processing width
	if `width' == -1 {
		local layout layout(autofitc)
		local width 
	}
	else {
		local width width(`width'cm)
	}
		
	*Table
	putdocx table table`table_no' = data(_all) , halign(center)  `width' `layout' // border(insideV, nil)  border(insideH, nil)  
	putdocx table table`table_no'(1,.), bold valign(center) shading(205 215 220) font(calibri, 11) // `b_outside'    
	*putdocx table table`table_no'(.,1), border(start) border(end) font(calibri, 11) 
	putdocx describe table`table_no' 
	local n_col =  r(ncols)
	forvalues i = 2 (1) `n_col' {
		putdocx table table`table_no'(.,`i'), halign(right)  font(calibri, 11)
	}
end

*Copy superscript characters from https://en.wikipedia.org/wiki/Unicode_subscripts_and_superscripts
*They don't all work!!!!


*Creating word document
cap putdocx clear
putdocx begin, font(calibri, 12)

*Title page
putdocx paragraph, halign(center)
putdocx text ("Automating trial reports"), bold underline font(calibri, 36) linebreak 

putdocx paragraph, halign(center)  spacing(before, 30pt)
putdocx image logo1.png // Add trial logo im	age here

putdocx paragraph, halign(center) spacing(before, 20pt)
putdocx text ("Version 0.1"),  linebreak
putdocx text ("Date: $S_DATE") 	  	

putdocx pagebreak

*Tables
local table_no = 1
putx_tab, filename("pt_eg3.dta") table_no(`table_no') title("First example") 

*Table from excel
local table_no = `table_no' + 1
import excel using example_excel, clear
save excel_example, replace
putx_tab, filename("excel_example.dta") table_no(`table_no') title("Some data from a spreadsheet") 
*Editing the alignment from default 
putdocx table table`table_no'(.,.), halign(left) 

*Saving document
putdocx save "eg_dmec_report2" , replace




	
