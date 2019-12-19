global master_set_ado 1
global test_data "Examples\Data\eg_data2"
global host_ado pt.ado

do $host_ado

cd "N:\Automating reporting\Git repository\post_table\Testing\Subroutines"

*Level 1 routines
do Testing\Subroutines\test_pt_pick_type 
do Testing\Subroutines\test_pt_su_bin  
do Testing\Subroutines\test_pt_su_mean_sd 
do Testing\Subroutines\test_pt_su_median_iqr 
do Testing\Subroutines\test_pt_su_n_per 
do Testing\Subroutines\test_pt_format_p
do Testing\Subroutines\pt_post_summaries_create

*Level 2 routines
do test_pt_su_estimates


global master_set_ado ""
