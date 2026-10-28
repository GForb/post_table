/*
Shared setup for the test files: points Stata at the code in this repository and
defines programs that record each test result without stopping the run.

Expects $pt_root to be the repository root. If it is not set, the current
working directory is used.

Reference files: set global pt_refs create before running to write reference
files that do not exist yet. Existing reference files are never overwritten;
to regenerate one, delete it first. Check new reference files by hand before
committing them.
*/

if "$pt_root" == "" global pt_root "`c(pwd)'"
cap confirm file "$pt_root/pt_base.ado"
if _rc {
	di as error `"pt_base.ado not found in "$pt_root". cd to the repository root or set global pt_root."'
	exit 601
}

* Use the code in this repository rather than any installed copy
adopath ++ "$pt_root"
foreach p in pt_base pt_sum pt_model pt_model_mt pt_subgroup {
	cap program drop `p'
}

if "$pt_n_tests" == "" {
	global pt_n_tests 0
	global pt_n_failed 0
	global pt_failed_list ""
	global pt_n_known 0
	global pt_known_list ""
}


*************Programs to record and report results***************
cap program drop pt_record
program define pt_record
	* Records the result of one test. name must not contain spaces.
	* known_bug marks a test that is expected to fail until a bug is fixed.
	syntax anything(name=name), rc(integer) [known_bug]
	global pt_n_tests = $pt_n_tests + 1
	if "`known_bug'" != "" {
		if `rc' {
			global pt_n_known = $pt_n_known + 1
			global pt_known_list "$pt_known_list `name'"
			di as text "KNOWN BUG: `name'"
		}
		else {
			global pt_n_failed = $pt_n_failed + 1
			global pt_failed_list "$pt_failed_list `name'(now_passes)"
			di as error "FAIL: `name' is marked known_bug but now passes. If the bug is fixed, remove known_bug."
		}
		exit
	}
	if `rc' {
		global pt_n_failed = $pt_n_failed + 1
		global pt_failed_list "$pt_failed_list `name'"
		di as error "FAIL: `name' (r(`rc'))"
	}
	else di as result "PASS: `name'"
end

cap program drop pt_check
program define pt_check
	* Compares the data in memory with a reference file
	syntax using/, name(string)
	cap confirm file `"`using'"'
	local exists = _rc == 0
	if "$pt_refs" == "create" & !`exists' {
		qui save `"`using'"'
		di as text `"REFERENCE WRITTEN: `name' -> `using' (check by hand before committing)"'
		exit
	}
	cap noisily cf _all using `"`using'"', verbose
	pt_record `name', rc(`=_rc')
end

cap program drop pt_expect
program define pt_expect
	* Checks one cell of the data in memory against an independently calculated value
	syntax varname, row(integer) value(string asis) name(string) [known_bug]
	local expected `value'
	local rc = `varlist'[`row'] != `"`expected'"'
	if `rc' di as text `"  `varlist'[`row']: expected "`expected'", got ""' `varlist'[`row'] `"""'
	pt_record `name', rc(`rc') `known_bug'
end

cap program drop pt_expect_error
program define pt_expect_error
	* Passes if the command after the colon stops with an error
	_on_colon_parse `0'
	local cmd `"`s(after)'"'
	local 0 `"`s(before)'"'
	syntax , name(string) [known_bug]
	cap noisily `cmd'
	local rc = _rc
	if `rc' == 0 di as text "  expected an error, but the command completed"
	pt_record `name', rc(`=`rc' == 0') `known_bug'
end

cap program drop pt_run_file
program define pt_run_file
	* Runs a do file from the repository root. Stopping with an error counts as a failure.
	syntax anything(name=file), name(string)
	local file `file'
	cap noisily do `"$pt_root/`file'"'
	local rc = _rc
	qui cd "$pt_root"
	if `rc' pt_record `name', rc(`rc')
end

cap program drop pt_test_summary
program define pt_test_summary
	di _n as text "{hline 60}"
	di as text "Tests run: $pt_n_tests    Failed: $pt_n_failed    Known bugs: $pt_n_known"
	foreach t in $pt_known_list {
		di as text "  known bug: `t'"
	}
	if $pt_n_failed > 0 {
		foreach t in $pt_failed_list {
			di as error "  failed: `t'"
		}
		di as error "TESTS FAILED"
	}
	else di as result "ALL TESTS PASSED"
	di as text "{hline 60}"
end
