capture program drop pt_check_depvar
*Internal: used by pt_model and pt_subgroup (and so pt_model_mt).
*Stops with an error if the outcome passed to the command is not the outcome of the
*last model, so one outcome's summaries are never posted next to another's estimate.
*After st commands (stcox, streg) the model's outcome is _t: the stset time or failure
*variable, _t or _d are accepted.

program define pt_check_depvar
	syntax varname
	local depvar `e(depvar)'
	if "`depvar'" == "" exit
	local accepted `depvar'
	if "`depvar'" == "_t" {
		local st_time : char _dta[st_bt]
		local st_fail : char _dta[st_bd]
		local accepted _t _d `st_time' `st_fail'
	}
	local ok : list varlist in accepted
	if !`ok' {
		di as error "`varlist' is not the outcome of the last model (`depvar')."
		di as error "Run the model for `varlist' immediately before posting its results."
		exit 198
	}
end
