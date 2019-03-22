	use "Examples\Data\eg_data2", clear
	
	*Opening postfile and posting header rows
	tempname postname
	postfile `postname' str100(col col2 col3 col4 col5) using "Examples\Results\Table_1", replace
	post `postname' ("") ("Intervention") ("") ("Control") ("")
	post `postname' ("Variable") ("N") ("Summary") ("N") ("Summary")

	*post_table command
	pt_base age bmi qol ethnicity smoking alcohol , post(`postname') n_analysis(cols) over(treat) su_label(append) order(group_treat)

	postclose `postname'
	
	*Creating table in Micorosoft Word
	use Examples\Results\Table_1.dta, clear
	cap putdocx clear
	putdocx begin
	putdocx table Table_1 = data(_all)
	putdocx table Table_1(.,.), font(calibri, 9)  border(all, single, lightgray, 0.5pt)
	putdocx table Table_1(1,2), colspan(2)
	putdocx table Table_1(1,3), colspan(2)
	putdocx table Table_1(1 2,.), bold
	putdocx table Table_1(.,2 (1) 5), halign(center)

	putdocx save "Examples\Results\Table_1", replace
