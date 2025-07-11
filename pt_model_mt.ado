capture program drop pt_model_mt
*run this program imediately following any regression command
*posts results from logistic regression as well as mean (sd) for each group to post file
*the reference treatment group must be the second of the treatment variables.
*version 0.3

prog define pt_model_mt
syntax varlist(numeric max = 1), postname(passthru) ///
	time_var(varname) ///
	[ ///
	type(passthru) ///
	treat(passthru) treat_grps(passthru) prim_treat(passthru) ///
	timepoints(numlist) ///
	gap(passthru)  ///
	su_decimal(passthru) est_decimal(passthru) miss_decimal(passthru) decimal(passthru) ///
	positive(passthru) ///
	missing(passthru) ///
	n_analysis(passthru) ///
	su_label(passthru) su_label_text(passthru) ///
	append_label(passthru) var_lab(passthru) ///
	per ///
	exp /// exponate results from regression
	icc /// calculate and report icc from analysis
	]

	if "`timepoints'" != "" local sub_grps sub_grps(`timepoints')
	pt_subgroup `varlist', sub_var(`time_var') `sub_grps' `postname' `type' `treat' `treat_grps' `prim_treat' `gap' `su_decimal' `est_decimal' `miss_decimal' `decimal' ///
		`positive' `missing' `n_analysis' `su_label' `su_label_text' `append_label' `var_lab' `per' `exp' `icc'
	
	
end



