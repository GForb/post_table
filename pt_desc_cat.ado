capture program drop pt_desc_cat
*Internal: used by pt_model and pt_subgroup with the descriptive option.
*Posts one row per level of a categorical outcome: no. (%) by treatment group, with
*empty estimate and p-value cells (and an empty icc cell with icc), so the rows fit a
*model results table.
*if: the observations summarised (outcome not missing, and the timepoint if any).
*all_if: the observations the missing counts are taken from (default all).
*Levels come from the whole variable, so every timepoint gets the same rows.

program define pt_desc_cat
	syntax varname [if], postname(string) treat(varname) treat_grps(numlist) ///
		[all_if(string) indent(string) su_label(string) su_label_text(string) missing(string) n_analysis(string) ///
		per(string) su_decimal(integer 1) miss_decimal(integer 1) icc]

	marksample touse, novarlist
	if `"`all_if'"' == "" local all_if 1
	local v `varlist'

	local measure1 "no. (%)"
	if "`missing'" == "brackets" local measure1 "`measure1' [missing]"
	if "`n_analysis'" == "brackets" local measure1 "`measure1' [no. included in analysis]"
	if "`su_label_text'" != "" local measure1 `su_label_text'
	local measure_post ""
	if "`su_label'" == "col" local measure_post ("`measure1'")

	local post_icc ""
	if "`icc'" != "" local post_icc ("")

	*numbers included and missing, which are the same for every level
	foreach i in `treat_grps' {
		qui count if `treat' == `i' & `touse'
		local n_`i' = r(N)
		qui count if `treat' == `i' & (`all_if')
		local n_all_`i' = r(N)
		local n_miss_`i' = `n_all_`i'' - `n_`i''
	}

	qui levelsof `v', local(levels)
	foreach l in `levels' {
		local level_label : label (`v') `l'
		local summaries ""
		local inan_cols ""
		local miss_cols ""
		foreach i in `treat_grps' {
			qui count if `treat' == `i' & `touse' & `v' == `l'
			local count = r(N)
			local per_str = string(`count' / `n_`i'' * 100, "%12.`su_decimal'f")
			local str_extra ""
			if "`missing'" == "brackets" local str_extra "[`n_miss_`i'']"
			if "`n_analysis'" == "brackets" local str_extra "[`n_`i'']"
			local su "`count' (`per_str'`per')"
			if "`str_extra'" != "" local su "`su' `str_extra'"
			local summaries `summaries' ("`su'")
			if "`n_analysis'" == "cols" local inan_cols `inan_cols' ("`n_`i''")
			if "`missing'" == "cols" {
				local miss_per = string(`n_miss_`i'' / `n_all_`i'' * 100, "%12.`miss_decimal'f")
				local miss_cols `miss_cols' ("`n_miss_`i'' (`miss_per'`per')")
			}
		}
		post `postname' (`"`indent'`level_label'"') `measure_post' `inan_cols' `miss_cols' `summaries' ("") ("") `post_icc'
	}
end
