version 13
class Table {
    string varname
    
    double value_label_col = 0
    double comment_col = 0
    
    double n_cols
    
    string postname = "table_post_name"
    string table_file
    double max_string_length = 244
}

prog .new
    if `"`0'"' != "" {
        .set_options `0'
    }
    .count_cols
    .open_postfile
end

prog .set_options
    syntax, filename(string) [comment_col *]
    .table_file = "`filename'"
    if "`comment_col'" != "" .comment_col = 1
end

prog .count_cols
    .n_cols = 1 + `.value_label_col' + `.comment_col'
end

prog .open_postfile
    forvalues i = 1 (1) `.n_cols' {
        local varnames `varnames' col`i'
    }
    postfile `.postname' str`.max_string_length'(`varnames') using `"`.table_file'"', replace
end

prog .post_row 
    syntax, [comment(passthru)]
    post `.postname' `.get_row, `comment''
end

prog .get_row
    syntax, [comment(passthru)]
    local label = `"`.get_label'"' 
    local body = `"`.get_body'"'
    local comment = `"`.get_comment, comment'"'
    local row `label' `body' `comment'
    class exit `row'
end

prog .get_label
syntax, [label(string) append(string)]
    if `"label"' == "" local label .varname.variable_label
    local label `label' `append'
    class exit (`"`label'"')
end

prog .get_body
    class exit ("")
end

prog .get_comment
    syntax, [comment(string)]
        if `.comment_col' == 0 {
            class exit ""
        }
        else {
            class exit ("`commnent'")
        }
end

prog .post_blank_row
    syntax, [n_blank_rows(integer 1)]
    forvalues i = 1 (1) `.n_cols' {
        local gap `gap' ("")
    }
    foralues i = 1 (1) `n_blank_rows' {
        post `.postname' `gap'
    }
end

prog .post_text_row
    syntax, columns(numlist) text(string)
    tokenize `colums'
    local i = 1
    while "``i''" != "" {
        gettoken  text``i'' `text': `text'
    }
    
    forvalues i = 1 (1)) `n_cols' {
        if test`i' == "" {
            local row `row' (`"`text`i''"')
        }
    }
    post `.postname' `row'
end

prog .close_table 
    syntax, [use]
    postclose `.postname'
    if "`use'" == "" preserve1
    use "`.table_file'", clear
    compress
    save "`.table_file'", replace
end
