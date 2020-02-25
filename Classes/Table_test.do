discard
.table = .Table.new, filename("Test_table\test table")
.table.close_table, use
assert `.table.n_cols' ==1
count
assert r(N) ==0

.table = .Table.new, filename("Test_table\test table") comment_col
.table.close_table, use
assert `.table.n_cols' ==2
count
assert r(N) ==0

.table = .Table.new, filename("Test_table\test table") comment_col
assert `"`.table.get_body'"' == ""
assert `"`.table.get_label'"' == `"("")"'
assert `"`.table.get_comment'"' == `"("")"'
assert `"`.table.get_comment, comment("test")'"' == `"("test")"'

`.table.post_row, comment("test")'
.table.close_table, use
count 
assert r(N) == 1

.table = .Table.new, filename("Test_table\test table") comment_col
.table.post_blank_row, n_blank_rows(3)
.table.close_table, use

assert `.table.n_cols' ==2
count
assert r(N) ==3

.table = .Table.new, filename("Test_table\test table") comment_col
.table.post_text_row, columns(2 1) text(`"World"' `"Hello"')
.table.close_table, use

assert `.table.n_cols' ==2
count
assert r(N) ==1
