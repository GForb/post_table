cd "N:\Automating reporting\Git repository\post_table\Examples\Data and results\All option examples"

global logs "N:\Automating reporting\Git repository\post_table\Examples\Data and results\All option examples"


cap prog drop putx_tab
prog  putx_tab
syntax , filename(string) table_no(integer) [title(string) header_rows(integer 1) header_cols(integer 1) ] 
	use  "`filename'", clear
	
	*Table title
	if "`title'" != ""{
		putdocx paragraph, halign(left) 
		putdocx text ("Table `table_no' - `title'"), bold
	}

	*Table
	putdocx table table`table_no' = data(_all) , halign(center)  layout(autofitc) `width' cellmargin(top, 1pt)   headerrow(`header_rows')
	putdocx table table`table_no'(.,.), font(calibri, 9)  border(all, single, lightgray, 0.5pt)
	qui putdocx describe table`table_no' 
	local n_col =  r(ncols)
	local n_row = r(nrows)
	
	*Formating header rows
	putdocx table table`table_no'(1 (1) `header_rows' ,.), bold valign(center) halign(center) shading(peachpuff)     // font, alignment and shading for header rows can be updated here
	
	*Formatting "header columns"
	putdocx table table`table_no'(.,1 (1) `header_cols'), halign(left)  // font and alignment for non header colums can be updated here

	*Formating body of table
	local body_col1 = `header_cols' + 1
	local body_row1 = `header_rows' + 1
	putdocx table table`table_no'(`body_row1' (1) `n_row',`body_col1' (1) `n_col'), halign(center)  // font and alignment for non header colums can be updated here
	

end

local start 0
local end 10
*Creating tables
foreach eg in 1 (1) 5 {
	di "`eg'"
	if `eg' >= `start' & `eg' <=`end' {
		putdocx clear
		putdocx begin, font(calibri, 12)
		putdocx paragraph, spacing(before, 20pt)
		putx_tab, filename("pts_eg`eg'.dta") table_no(1)
		putdocx pagebreak
		putdocx save "doc_`eg'.docx" , replace
	}
}

local start 0
local end 10
*Creating markdown
foreach eg in 1 (1) 5 {
	di "`eg'"
	if `eg' >= `start' & `eg' <`end' {
		qui markdoc "$logs\pts_eg`eg'.smcl", export(docx) replace // creating word doc of text
	}
}

local refresh_title 0
if `refresh_title' ==1 {
	*Title page
	putdocx clear
	putdocx begin, font(calibri, 12)
	putdocx paragraph, halign(center)  style(Title)  spacing(before, 60pt)
	putdocx text ("Comprehensive examples for the use of pt_base ")	

	putdocx paragraph, halign(center) spacing(before, 20pt) spacing(after, 1.0)
	putdocx text ("Version 1.1.0"),  linebreak
	putdocx text ("Date: $S_DATE") 	  	

	putdocx pagebreak
	putdocx pagebreak

	putdocx save "doc_title.docx" , replace
}
*Merging documents
foreach eg in  $eg_list {
	local merge_list `merge_list' ptb_eg`eg'.docx doc_`eg'.docx
}

di "`merge_list'"

putdocx append doc_title.docx `merge_list', saving(pt_sum_comprehensive_examples, replace) 



