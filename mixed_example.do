clear

set obs 300

gen intercept =  rnormal(0,1)
gen treat = rbinomial(1, 0.5)
gen baseline = rnormal(0, 1)
gen id = _n
expand  3
bysort id: gen timepoint = _n 

gen y = intercept + treat + timepoint + rnormal(0,1)


mixed y  baseline i.treat##i.timepoint || id: , nocons res(unstructured, t(timepoint))

levelsof timepoint, local(timepoints)
foreach t in `timepoints' {
	lincom 1.treat + 1.treat#`t'.timepoint
}
