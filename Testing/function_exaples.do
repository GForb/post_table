get_type sex
local type1 r(type)
di `type1'
		
format_p, p(0.05)
		
regress caps_ca_5_1 i.allocation##i.sex
lincom 1.allocation + 1.allocation#1.sex
get_ests_from_lincom, est_decimal(1)
return list

syntax `varlist', treat(string) treat_grps(numlist) inanalysis() sub_var() sub_var_level() missing(string) n_analysis(string) type(string) var_label(string) su_decimal(integer) [positive(integer 1) percent su_label_text(string) su_label(string)]

gen in_analysis = 1
get_summaries sex, treat(allocation) treat_grps(0 1 2 3 4) inanalysis(in_analysis) sub_var(time) sub_var_level(0) ///
	missing("cols") n_analysis("cols") type("bin") su_decimal(1) sub_lab("Time 0") var_label("Time")
