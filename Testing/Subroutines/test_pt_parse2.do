*Unit test for pt_parse

use "$test_data", clear

*Executing pt_regress
if "$master_set_ado" == "" do "$host_ado"

set trace on

cap prog drop test
prog define test
	syntax anything, *
	local i = 0
	while "``++i''" ! = "" {
		di "``i''"
	}
	di "`anything'"
end

set trace off
test hello, opt1(1) opt2 opt3(hello))

*pt_base_parse2
