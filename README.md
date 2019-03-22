# post_table_base
*post_table_base* is a Stata package to help with reporting clinical trial results. The package contains two commands, pt_base and pt_sum, that add rows to an open postfile, which can then be turned into tables for microsoft word with _putdocx_, or into another document format with another second stage package.

To install via stata enter the following command:

`net install post_table_base, from("https://raw.githubusercontent.com/GForb/post_table_base/master")`

See the do file _post_table_example_ for examples of syntax and the do file _putdocx_tables_example.do_ for an example of how to create word documents with from your do file.

An example workflow using the package to create a baseline table is:

````
	use data, clear
	
	*Opening postfile and posting header rows
	postfile postname str100(col col2 col3 col4), using Table_1, replace
	post postname ("Variable") ("Intervention") ("") ("Control") ("")
	post postname ("Variable") ("N") ("Summary") ("N") ("Summary")

	*post_table command
	pt_table _list of baseline variables_, postfile(postname) n_analysis(cols) over(treatment_group) su_label(append)

	postclose postname
	
	*Creating table in Micorosoft Word
	use Table_1.dta, clear
	putdocx begin
	putdocx table Table_1 = data(_all)
	putdocx table table`table_no'(.,.), font(calibri, 9)  border(all, single, lightgray, 0.5pt)
	putdocx table Table_1(1,2), colspan(2)
	putdocx table Table_1(1,3), colspan(2)
	putdocx save Table_1, replace
````

Note: If you want to use <sup>superscripts</sup> or <sub>subscripts</sub> in tables the unicode characters can be copied from https://en.wikipedia.org/wiki/Unicode_subscripts_and_superscripts
ᵃ ᵇ ᶜ ᵈ	ᵉ ᶠ ᵍ ʰ ⁱ ʲ ᵏ ˡ ᵐ ⁿ ᵒ ᵖ ʳ ˢ ᵗ ᵘ	ᵛ ʷ ˣ ʸ ᶻ ⁰ ¹ ² ³  ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ 