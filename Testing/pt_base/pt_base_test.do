global ref_data "N:\Automating reporting\Git repository\post_table\Testing\pt_base\Reference data"
global test_data "N:\Automating reporting\Git repository\post_table\Testing\pt_base\Test data"

cd "$ref_data"
local files: dir . files "*dta"
foreach f in `files' {
	use `f', clear
	di as text "Testing `f'"
	cap noisily  cf _all using "$test_data\\`f'", verbose
	local errors = r(Nsum)
	if `errors' == 0 di as result "Test of `f' passed"
	if `errors' > 0 di as error "Test of `f' failed" 

}
