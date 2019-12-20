*-------------------------------------------------------------------------------
*pt_summarise_bin
pt_summarise_bin smoking
di "`s(sum)'"
assert "`s(sum)'" == "73 (8.1)" 

pt_summarise_bin smoking, per
di "`s(sum)'"
assert "`s(sum)'" == "73 (8.1%)" 

pt_summarise_bin smoking, per decimal(2)
di "`s(sum)'"
assert "`s(sum)'" == "73 (8.11%)"

pt_summarise_bin smoking, per decimal(2) count_only
di "`s(sum)'"
assert "`s(sum)'" == "73"

pt_summarise_bin smoking if treat ==1
di "`s(sum)'"
assert "`s(sum)'" == "37 (8.1)"

pt_summarise_bin smoking if treat ==1, brackets([yolo])
di "`s(sum)'"
assert "`s(sum)'" == "37 (8.1)[yolo]"

*-------------------------------------------------------------------------------
*pt_count_missing_non_missing
pt_count_missing_non_missing smoking, missing
di "`s(sum)'"
assert "`s(sum)'" == "100 (10.0)" 

pt_count_missing_non_missing smoking, per 
di  "`s(sum)'"
assert  "`s(sum)'" == "900 (90.0%)" 

pt_count_missing_non_missing smoking, per decimal(2) missing
di  "`s(sum)'"
assert  "`s(sum)'" == "100 (10.00%)" 

pt_count_missing_non_missing smoking, per decimal(2) count_only 
di  "`s(sum)'"
assert  "`s(sum)'" == "900"

pt_count_missing_non_missing smoking if treat ==1, missing
di  "`s(sum)'"
assert  "`s(sum)'" == "52 (10.3)"

pt_count_missing_non_missing smoking if treat ==1
di  "`s(sum)'"
assert  "`s(sum)'" == "454 (89.7)"

*-------------------------------------------------------------------------------
*pt_summarise_cont
pt_summarise_cont age
di "`s(sum)'"
assert "`s(sum)'" == "44.8 (10.1)"

pt_summarise_cont age, decimal(2) per count_only
di "`s(sum)'"
assert "`s(sum)'" == "44.75 (10.09)" 

pt_summarise_cont age,  per count_only brackets([yolo])
di "`s(sum)'"
assert "`s(sum)'" == "44.8 (10.1)[yolo]"

pt_summarise_cont age if treat ==1,  per count_only brackets([yolo])
di "`s(sum)'"
assert "`s(sum)'" == "44.9 (10.1)[yolo]"

pt_summarise_cont age if treat ==0,  per count_only brackets([yolo])
di "`s(sum)'"
assert "`s(sum)'" == "44.6 (10.1)[yolo]"

*-------------------------------------------------------------------------------
*pt_summarise_skew
pt_summarise_skew age
di "`s(sum)'"
assert "`s(sum)'" == "44.6 (37.7-51.5)"

pt_summarise_skew age, decimal(2) per count_only
di "`s(sum)'"
assert "`s(sum)'" == "44.59 (37.73-51.50)"

pt_summarise_skew age,  per count_only brackets([yolo])
di "`s(sum)'"
assert "`s(sum)'" == "44.6 (37.7-51.5)[yolo]"

pt_summarise_skew age if treat ==1,  per count_only brackets([yolo])
di "`s(sum)'"
assert "`s(sum)'" == "45.0 (37.5-51.5)[yolo]"

pt_summarise_skew age if treat ==0,  per count_only brackets([yolo])
di "`s(sum)'"
assert "`s(sum)'" == "44.1 (38.0-51.4)[yolo]"

*-------------------------------------------------------------------------------
*pt_summarise_misstable
pt_summarise_misstable smoking
di "`s(sum)'"
assert "`s(sum)'" == "100 (10.0)" 

pt_summarise_misstable smoking, per 
di  "`s(sum)'"
assert  "`s(sum)'" == "100 (10.0%)" 

pt_summarise_misstable smoking, per decimal(2) 
di  "`s(sum)'"
assert  "`s(sum)'" == "100 (10.00%)" 

pt_summarise_misstable smoking, per decimal(2) count_only 
di  "`s(sum)'"
assert  "`s(sum)'" == "100"

pt_summarise_misstable smoking if treat ==1, 
di  "`s(sum)'"
assert  "`s(sum)'" == "52 (10.3)"

pt_summarise_misstable smoking if treat ==0
di  "`s(sum)'"
assert  "`s(sum)'" == "48 (9.7)"
