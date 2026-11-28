*Counts the columns a post_table command posts, without data, a model or a postfile.
*Called by each command when the countcolumns option is given; also usable on its own:
*	pt_count_columns pt_model, treat_grps(0 1 2) n_analysis(cols) icc
*Columns are (per group) x k + fixed, k being the number of treat (or over) groups.
*The layout here must match the post commands in each .ado; the tests check that it does.

prog define pt_count_columns, rclass
syntax anything(name=cmd), [ ///
	treat_grps(numlist) over(string) over_grps(numlist) overall(string) ///
	su_label(string) n_analysis(string) missing(string) icc nosummary ///
	stats(string) order(string) sum_cols_first cat_col comment(string) ///
	* ]

	local cmd = strtrim("`cmd'")
	if !inlist("`cmd'", "pt_base", "pt_sum", "pt_model", "pt_model_mt", "pt_subgroup") {
		di as error "countcolumns: unknown command `cmd'"
		exit 198
	}

	*blocks of columns, in order: name, and how many columns per group (per) or in all (fixed)
	local nb = 0
	local note ""

	if inlist("`cmd'", "pt_model", "pt_model_mt", "pt_subgroup") {
		local grp_name "treat group"
		local k ""
		if "`treat_grps'" != "" local k : word count `treat_grps'
		local nb = `nb' + 1
		local name`nb' "label"
		local fixed`nb' 1
		if "`su_label'" == "col" & "`summary'" == "" {
			local nb = `nb' + 1
			local name`nb' "summary label"
			local fixed`nb' 1
		}
		if "`n_analysis'" == "cols" {
			local nb = `nb' + 1
			local name`nb' "no. in analysis, one per treat group"
			local per`nb' 1
		}
		if "`missing'" == "cols" {
			local nb = `nb' + 1
			local name`nb' "no. missing, one per treat group"
			local per`nb' 1
		}
		if "`summary'" == "" {
			local nb = `nb' + 1
			local name`nb' "summary, one per treat group"
			local per`nb' 1
		}
		local nb = `nb' + 1
		local name`nb' "estimate (CI)"
		local fixed`nb' 1
		local nb = `nb' + 1
		local name`nb' "p-value"
		local fixed`nb' 1
		if "`icc'" != "" {
			local nb = `nb' + 1
			local name`nb' "ICC"
			local fixed`nb' 1
		}
	}

	if inlist("`cmd'", "pt_base", "pt_sum") {
		*groups: the over levels (plus an overall column with overall()), or one overall column
		local grp_name "over group"
		local k ""
		if "`over_grps'" != "" local k : word count `over_grps'
		local overall_col = "`over'" != "" & inlist("`overall'", "first", "last")
		local grp_desc "one per `grp_name'"
		if "`over'" == "" local grp_desc "one overall (no over())"
		if `overall_col' local grp_desc "one per over group and one overall (`overall')"
	}

	if "`cmd'" == "pt_base" {
		*missing() and n_analysis() take several words, e.g. missing(cols %)
		local miss_cols = 0
		foreach w in `missing' {
			if "`w'" == "cols" local miss_cols = 1
		}
		local n_cols = 0
		foreach w in `n_analysis' {
			if "`w'" == "cols" local n_cols = 1
		}
		if "`order'" == "" | "`order'" == "group_treat" local order = cond("`order'" == "", "group_sum", "group_over")
		local nb = `nb' + 1
		local name`nb' "label"
		local fixed`nb' 1
		if "`su_label'" == "col" {
			local nb = `nb' + 1
			local name`nb' "summary label"
			local fixed`nb' 1
		}
		if "`cat_col'" != "" {
			local nb = `nb' + 1
			local name`nb' "category (cat_col)"
			local fixed`nb' 1
		}
		if "`order'" == "group_sum" {
			local blocks ""
			if `n_cols' local blocks `blocks' n
			if `miss_cols' local blocks `blocks' miss
			if "`sum_cols_first'" != "" local blocks sum `blocks'
			else local blocks `blocks' sum
			foreach b in `blocks' {
				local nb = `nb' + 1
				if "`b'" == "n" local name`nb' "no. with data, `grp_desc'"
				if "`b'" == "miss" local name`nb' "no. missing, `grp_desc'"
				if "`b'" == "sum" local name`nb' "summary, `grp_desc'"
				local per`nb' 1
			}
		}
		else {
			*group_over: for each group, its columns side by side
			local inner "summary"
			local m = 1
			if `n_cols' | `miss_cols' {
				local m = 2
				*only one of the two is posted per group when both are given
				local extra = cond(`n_cols' & `miss_cols', "no. with data or no. missing", cond(`n_cols', "no. with data", "no. missing"))
				if "`sum_cols_first'" != "" local inner "summary, `extra'"
				else local inner "`extra', summary"
				if `n_cols' & `miss_cols' local note "With order(group_over), missing(cols) and n_analysis(cols) together give one column per group, not two: category rows hold no. with data, other rows no. missing."
			}
			local nb = `nb' + 1
			local name`nb' "for each group (`grp_desc'): `inner'"
			local per`nb' `m'
		}
		if `"`comment'"' != "" {
			local nb = `nb' + 1
			local name`nb' "comment"
			local fixed`nb' 1
		}
	}

	if "`cmd'" == "pt_sum" {
		if "`order'" == "" local order group_over
		local n_stats : word count `stats'
		if `n_stats' == 0 {
			di as error "countcolumns: pt_sum needs stats()"
			exit 198
		}
		local nb = `nb' + 1
		local name`nb' "label"
		local fixed`nb' 1
		if "`order'" == "group_sum" {
			foreach s in `stats' {
				local nb = `nb' + 1
				local name`nb' "`s', `grp_desc'"
				local per`nb' 1
			}
		}
		else {
			local nb = `nb' + 1
			local name`nb' "for each group (`grp_desc'): `stats'"
			local per`nb' `n_stats'
		}
		if `"`comment'"' != "" {
			local nb = `nb' + 1
			local name`nb' "comment"
			local fixed`nb' 1
		}
	}

	*totals; an overall column in pt_base/pt_sum is one more group, so goes in the fixed part
	local per_level = 0
	local fixed = 0
	forvalues b = 1/`nb' {
		if "`per`b''" != "" local per_level = `per_level' + `per`b''
		else local fixed = `fixed' + `fixed`b''
	}
	local extra = 0
	if inlist("`cmd'", "pt_base", "pt_sum") local extra = `overall_col'
	local fixed = `fixed' + `per_level' * `extra'
	*groups actually posted (g); with no over() there is one group and nothing depends on k
	local g ""
	if "`k'" != "" local g = `k' + `extra'
	local no_over = inlist("`cmd'", "pt_base", "pt_sum") & "`over'" == ""
	if `no_over' {
		local fixed = `fixed' + `per_level'
		local per_level = 0
		local g 1
	}
	if `per_level' == 0 & "`g'" == "" local g 1

	local formula "`per_level' x k + `fixed'"
	if `per_level' == 0 local formula "`fixed'"
	local k_desc "k = number of `grp_name's"
	if `extra' local k_desc "k = number of over groups; the overall column is in the + `fixed'"
	*display
	if `per_level' == 0 local k_desc "whatever the number of groups"
	if `no_over' local k_desc "(no over(), so one summary column)"
	di as text _newline "`cmd': " as result "`formula'" as text " columns, `k_desc'"
	local n_cols_total ""
	if `per_level' == 0 local n_cols_total = `fixed'
	else if "`k'" != "" {
		local n_cols_total = `per_level' * `k' + `fixed'
		di as text "  with k = `k': " as result "`n_cols_total'" as text " columns"
	}
	di as text ""
	di as text "  columns       content"
	local pos = 1
	local columns ""
	forvalues b = 1/`nb' {
		if "`per`b''" != "" {
			local mult = cond(`per`b'' == 1, "", "`per`b'' x ")
			local size_desc = cond(`extra', "`mult'(k+1)", "`mult'k")
			if "`g'" != "" {
				local last = `pos' + `per`b'' * `g' - 1
				local size_desc = cond(`last' > `pos', "`pos'-`last'", "`pos'")
				local pos = `last' + 1
			}
		}
		else {
			local size_desc "1"
			if "`g'" != "" {
				local size_desc "`pos'"
				local pos = `pos' + 1
			}
		}
		di as result "  " %-12s "`size_desc'" as text "  `name`b''"
		local columns `"`columns'`=cond(`b' > 1, "; ", "")'`size_desc': `name`b''"'
	}
	if "`note'" != "" di as text _newline "  Note: `note'"

	return scalar per_level = `per_level'
	return scalar fixed = `fixed'
	return local formula "`formula'"
	return local columns `"`columns'"'
	if "`k'" != "" return scalar k = `k'
	if "`n_cols_total'" != "" return scalar n_cols = `n_cols_total'

end
