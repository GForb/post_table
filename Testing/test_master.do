/*
Runs all post_table tests and prints a summary. Failed tests are counted and
listed at the end rather than stopping the run.

Run from the repository root:
	cd "<path to post_table>"
	do Testing/test_master.do

or in batch mode (Stata's exit code is 0 even on failure, so check the log):
	stata-mp -b do Testing/test_master.do
	grep -q "ALL TESTS PASSED" test_master.log
*/

global pt_root "`c(pwd)'"
global pt_n_tests ""
do "$pt_root/Testing/test_helpers.do"


*Testing pt_base
pt_run_file "Examples/Creating comprehensive examples/pt_base_comprehensive_examples.do", name(pt_base_examples)
pt_run_file "Testing/pt_base/pt_base_test.do", name(pt_base_test)

*Testing pt_sum
pt_run_file "Examples/Creating comprehensive examples/pt_sum_comprehensive_examples.do", name(pt_sum_examples)
pt_run_file "Testing/pt_sum/pt_sum_test.do", name(pt_sum_test)

*Testing pt_model
pt_run_file "Testing/pt_model/test_pt_model.do", name(pt_model_test)

*Testing pt_model_mt
pt_run_file "Testing/pt_model_mt/test_pt_model_mt.do", name(pt_model_mt_test)


pt_test_summary
