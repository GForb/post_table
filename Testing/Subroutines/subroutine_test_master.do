global master_set_ado 1
global test_data "N:\Automating reporting\Git repository\post_table\Examples\Data\eg_data2"
global host_ado "N:\Automating reporting\Git repository\post_table\pt_regress.ado"

do "N:\Automating reporting\Git repository\post_table\pt_regress.ado"

cd "N:\Automating reporting\Git repository\post_table\Testing\Subroutines"

*Level 1 routines
do test_pt_pick_type 
do test_pt_su_bin  
do test_pt_su_mean_sd 
do test_pt_su_median_iqr 
do test_pt_su_n_per 
do test_pt_format_p
pt_post_summaries_create

*Level 2 routines
do test_pt_su_estimates


global master_set_ado ""
