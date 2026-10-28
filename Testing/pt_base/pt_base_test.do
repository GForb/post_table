* Compares each table written by pt_base_comprehensive_examples.do with its reference copy

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap program list pt_check
if _rc do "$pt_root/Testing/test_helpers.do"

local ref_data "$pt_root/Testing/pt_base/Reference data"
local test_data "$pt_root/Testing/pt_base/Test data"

local files: dir "`ref_data'" files "*dta"
foreach f in `files' {
	use "`ref_data'/`f'", clear
	pt_check using "`test_data'/`f'", name(pt_base:`f')
}
