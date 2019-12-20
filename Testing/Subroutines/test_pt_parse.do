cap prog drop pt_test
prog pt_test
    di `"`0'"'
end 

pt test gender cont(age qol if age ==3, subopt("opt1") opt2) ethnicity if age ==2, option1 option2 type(bin)
pt test  cont(age qol if age ==3, subopt("opt1") opt2) if age ==2, option1 option2 type(bin)

