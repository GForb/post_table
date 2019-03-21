cd "N:\Automating reporting\Git repository\post_table\Examples\Data and results\All option examples"
use eg_data2, clear

*Overall
su age 
tab gender
tab ethnicity

*By treatment group
bysort treat: su age
tab gender treat, col
tab ethnicity treat, col

su qol, detail
bysort treat: su qol, detail

bysort treat: count

count if age ==.
count if gender ==.
count if qol ==.
count if ethnicity ==.

bysort treat: count if qol ==.
bysort treat: count if ethnicity ==.



	
tab smoking treat, col
tab alcohol treat, col

misstable sum age qol gender ethnicity
misstable sum age qol gender ethnicity if treat ==1
misstable sum age qol gender ethnicity if treat ==0


su age if ethnicity ==4
bysort treat: su age if ethnicity ==4
