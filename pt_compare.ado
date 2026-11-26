*Works out which treatment comparisons to report. Used by pt_model and pt_subgroup.
*Each comparison is "a vs b", meaning a minus b. Default is every pair of arms, higher value vs lower value.
*version 0.1

prog define pt_compare, rclass
syntax , treat(varname) treat_grps(numlist) [compare(string)]

	*default comparisons: arms 1 2 3 give 2v1 3v1 3v2
	if `"`compare'"' == "" {
		numlist "`treat_grps'", sort
		local arms `r(numlist)'
		local n_arms: word count `arms'
		forvalues high = 2 (1) `n_arms' {
			local a: word `high' of `arms'
			forvalues low = 1 (1) `=`high' - 1' {
				local b: word `low' of `arms'
				local compare `compare' `a'v`b'
			}
		}
	}

	local n = 0
	foreach pair in `compare' {
		if !regexm("`pair'", "^[0-9]+v[0-9]+$") {
			di as error "compare(): `pair' is not valid. Write each comparison as two arm values joined by v, for example compare(2v1 3v1)."
			exit 198
		}
		local arm_pair = subinstr("`pair'", "v", " ", 1)
		local a: word 1 of `arm_pair'
		local b: word 2 of `arm_pair'
		if `a' == `b' {
			di as error "compare(): `pair' compares an arm with itself."
			exit 198
		}
		foreach arm in `a' `b' {
			if !`: list arm in treat_grps' {
				di as error "compare(): arm `arm' is not in treat_grps(`treat_grps')."
				exit 198
			}
		}
		local n = `n' + 1
		local label_a: label (`treat') `a'
		local label_b: label (`treat') `b'
		return local a`n' `a'
		return local b`n' `b'
		return local label`n' `"`label_a' vs `label_b'"'
	}
	return scalar n = `n'
end
