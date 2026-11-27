capture program drop pt_check_converged
*Internal: used by pt_model and pt_subgroup (and so pt_model_mt).
*Stops with an error if the last model did not converge (e(converged) is 0), so its
*estimates are never posted as if they were reliable. Commands that iterate (glm, logit,
*mixed, melogit, meglm, mestreg, stcox with frailty, ...) set e(converged); commands that
*don't (regress) leave it empty, which passes. Not detectable after mi estimate, which
*doesn't set it. The commands' noconvergencecheck option skips this check.

program define pt_check_converged
	if "`e(converged)'" == "0" {
		di as error "The last model (`e(cmd)') did not converge, so its estimates are not reliable."
		di as error "Change the model so that it converges (for example fewer covariates or a different estimation method),"
		di as error "or add the noconvergencecheck option to post its results anyway."
		exit 430
	}
end
