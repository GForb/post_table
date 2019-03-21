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
