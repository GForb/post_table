# post_table
*post_table* is a Stata package to help with reporting clinical trial results. The package contains two commands, pt_base and pt_sum, that add rows to an open postfile, which can then be turned into tables for microsoft word with _putdocx_, or into another document format with another second stage package.

To install via stata enter the following command:

`net install post_table, from("https://raw.githubusercontent.com/GForb/post_table_base/master")`

See the do files in the Examples folder for syntax and examples of how to create word documents with from your do file.

An example workflow using the package to create a baseline table is:

````stata
	use data, clear
	
	*Opening postfile and posting header rows
	tempname postname
	postfile `postname' str100(col col2 col3 col4 col5) using Table_1, replace
	post `postname' ("") ("Intervention") ("") ("Control") ("")
	post `postname' ("Variable") ("N") ("Summary") ("N") ("Summary")

	*post_table command
	pt_base age bmi qol ethnicity smoking alcohol , post(`postname') n_analysis(cols) over(treat) su_label(append) order(group_treat)

	postclose `postname'
	
	*Creating table in Micorosoft Word
	use Table_1.dta, clear
	cap putdocx clear
	putdocx begin
	putdocx table Table_1 = data(_all)
	putdocx table Table_1(.,.), font(calibri, 9)  border(all, single, lightgray, 0.5pt)
	putdocx table Table_1(1,2), colspan(2) // merging header cells 
	putdocx table Table_1(1,3), colspan(2) // merging header cells
	putdocx table Table_1(1 2,.), bold
	putdocx table Table_1(.,2 (1) 5), halign(center)
	putdocx save Table_1, replace
````

Note: If you want to use <sup>superscripts</sup> or <sub>subscripts</sub> in tables the unicode characters can be copied from the line below or https://en.wikipedia.org/wiki/Unicode_subscripts_and_superscripts

ᵃ ᵇ ᶜ ᵈ	ᵉ ᶠ ᵍ ʰ ⁱ ʲ ᵏ ˡ ᵐ ⁿ ᵒ ᵖ ʳ ˢ ᵗ ᵘ	ᵛ ʷ ˣ ʸ ᶻ  ¹ ² ³
