discard
.table = .Table.new, filename("Test_tables\test table")
.table.close_table, use
assert `.table.n_cols' ==1
count
assert r(N) ==0

.table = .Table.new, filename("Test_tables\test table") comment_col
.table.close_table, use
assert `.table.n_cols' ==2
count
assert r(N) ==0

.table = .Table.new, filename("Test_tables\test table") comment_col
.table.post_row, comment("test")

.table.post_blank_row, n_blank_rows(3)
.table.close_table, use

assert `.table.n_cols' ==2
count
assert r(N) ==3
