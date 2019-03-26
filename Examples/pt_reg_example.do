use "C:\Users\k1811974\PCTU Files\Automating tables Dec 18\Example data and results\cr_example_data", clear

gen count_outcome = rpoisson(3)

gen time_to = rpoisson(365)
gen tt_event = cond(time_to < 356, 1, 0)
replace time_to = 365 if time_to >365


regress qol treat 
mat A = r(table)
mixed qol treat || cid:
mat B = r(table)
	
logit died_d28 treat
mat C = r(table)
melogit died_d28 treat || cid:
mat D = r(table)

nbreg count_outcome treat
mat E = r(table)

stset time_to, failure(tt_event)
stcox treat
mat F = r(table)

streg treat, distribution(w)
mat G = r(table)

mat list A
mat list B
mat list C
mat list D
mat list E
mat list F
mat list G

di G[_se, treat]
