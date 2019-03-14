/*
#Instructions
This do file creates a word document combining the ds example and the bl example as well as creating a title page.


*/


cd  "N:\Automating reporting\Example data and results" // set path for where your data is stored and results will be saved




**********************************************************************************************************


*Creating word document
cap putdocx clear
putdocx begin, font(calibri, 12)

*Title page
putdocx paragraph, halign(center)
putdocx text ("Automating trial reports"), bold underline font(calibri, 36) linebreak 

putdocx paragraph, halign(center)  spacing(before, 30pt)
putdocx image logo1.png // Add trial logo im	age here

putdocx paragraph, halign(center) spacing(before, 20pt) spacing(after, 1.8)
putdocx text ("Version 0.1"),  linebreak
putdocx text ("Date: $S_DATE") 	  	

putdocx paragraph, halign(right) spacing(after, 0) 
putdocx text ("Statistician: Gordon Forbes"),  linebreak
putdocx text ("gordon.forbes@kcl.ac.uk")

putdocx pagebreak


*Saving document
putdocx save example_title_page, replace

*Merging with a document already written, and the tables we saw earlier
putdocx append example_title_page example_doc ds_examples bl_examples, saving(example_report, replace)


