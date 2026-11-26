capture program drop pt_model_level
*Internal: used by pt_model and pt_subgroup (and so pt_model_mt).
*Returns in r(level) the confidence level of the intervals in a model results table
*(a copy of r(table)), worked back from its critical value and degrees of freedom.
*r(level) is missing if the table has no usable crit row. Used only to check that the
*command's level() matches the model's; the commands' nolevelcheck option skips the check.

program define pt_model_level, rclass
	args table
	local level = .
	local crit_row = rownumb(`table', "crit")
	local df_row = rownumb(`table', "df")
	if `crit_row' < . {
		forvalues k = 1/`=colsof(`table')' {
			local crit = `table'[`crit_row', `k']
			if `crit' < . & `crit' > 0 {
				local df = .
				if `df_row' < . local df = `table'[`df_row', `k']
				if `df' < . local level = 100 * (1 - 2 * ttail(`df', `crit'))
				else local level = 100 * (2 * normal(`crit') - 1)
				local level = round(`level', 0.01)
				continue, break
			}
		}
	}
	return scalar level = `level'
end
