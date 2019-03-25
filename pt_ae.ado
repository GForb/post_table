capture program drop pt_ae

prog define pt_ae
version 15.1
syntax varname [if] [in] , POSTname(string) ///
	[ ///
	over(varname) ///
	over_grps(numlist) ///
	overall(string) ///
	gap(integer 0) /// adds empty rows to baseline table after each variable
	row_lab(string) /// Overides default variable label
	comment(string) /// adds column to end of table with text contained in string
	]

*************IF****************
if "`if'" != "" | "`in'" != "" {
	preserve
	keep `if' `in'	
}

*Setting default for over and extracting the levels of `over'
if "`over'" != "" {
	if "`over_grps'" == "" levelsof `over', local(over_grps)
	if "`overall'" == "first" local over_grps overall `over_grps'
	if "`overall'" == "last" local over_grps  `over_grps' overall
}
if "`over'" == "" local over_grps overall	

*Comments
if "`comment'" != "" & "`comment'" != "no comment" local comment1 ("`comment'")
if "`comment'" == "no comment" local comment1 ("")


 
if "`row_lab'" == "" local row_lab "Adverse events"

tempvar pickone
egen `pickone' = tag(`varname')
 
foreach i in `over_grps' {
	if "`i'" == "overall" {
		count 
		local n_events = r(N) 
		count if `pickone' ==1
		local n_participants = r(N)
		local summaries `summaries' ("`n_events' (`n_participants')")
	} 
	else {
		count if `over' == `i'
		local n_events = r(N) 
		count if `pickone' ==1 & `over' == `i'
		local n_participants = r(N)
		local summaries `summaries' ("`n_events' (`n_participants')")
	}
}	

*Posting
post `postname' ("`row_lab'")  `summaries' `comment1'

*Gaps
local summaries ""
foreach i in `over_grps' {
	local summaries `summaries' ("")	
	if "`comment'" != "" local comment1 ("")
}

if `gap' > 0 {
	forvalues i = 1 (1) `gap' {
		post `postname' ("")  `summaries' `comment1'
	}
}

*************IF****************
if "`if'" != "" | "`in'" != ""  restore

end


end

