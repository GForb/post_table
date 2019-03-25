cd "N:\Automating reporting\Git repository\post_table"


*Testing pt_base
do pt_base.ado
do "Examples\Creating comprehensive examples\pt_base_comprehensive_examples.do"
do "Testing\pt_base\pt_base_test.do"



*Testing pt_sum
cd "N:\Automating reporting\Git repository\post_table"
do pt_sum.ado
do "Examples\Creating comprehensive examples\pt_sum_comprehensive_examples.do"
do "Testing\pt_sum\pt_sum_test.do"

