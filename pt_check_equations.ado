capture program drop pt_check_equations
*Internal: used by pt_model and pt_subgroup (and so pt_model_mt).
*Stops with an error if the treatment variable is in more than one equation of the model
*(for example mlogit, zero-inflated models, heckman, sem/gsem with several outcomes):
*columns are looked up by name, which would silently use the first equation.
*table: a copy of r(table). Interaction columns (e.g. 1.arm#2.time) are not counted.

program define pt_check_equations
	args table treat
	local names : colnames `table'
	local eqs : coleq `table'
	local treat_eqs ""
	local k = 0
	foreach name of local names {
		local ++k
		if regexm("`name'", "^([0-9]+[bno]*\.)?`treat'$") {
			local eq : word `k' of `eqs'
			local treat_eqs : list treat_eqs | eq
		}
	}
	local n_eqs : word count `treat_eqs'
	if `n_eqs' > 1 {
		di as error "`treat' is in more than one equation of the model (`treat_eqs')."
		di as error "Models with several equations (for example mlogit, zero-inflated models or heckman) are not currently supported."
		di as error "If you would like this, please open an issue at https://github.com/GForb/post_table/issues or contact the package developers."
		exit 198
	}
end
