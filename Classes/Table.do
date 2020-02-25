version 13
class TableRow {
    *Variable properties
    string varname
    double label_col = 1


}

prog .new
    if "`0'" != "" {
        .set_options `0'
    }
    .count_cols
    .open_postfile
end

prog .count_cols
    .n_cols = 1 + `.label_col' + `.comment_col'
end

prog .open_postfile
    tempname postname
    tempfile table_file
    forvalues i = 1 (1) `.n_cols' {
        local varnames `varnames' `col`i''
    }
    postfile `postname' str`.max_string_length'(`varnames'), using(`table_file')
    .postname = "`postname'"
    .table_file = "`table_file'"
end


prog .get_row
    class exit `.get_varlabel' `.get_body' `.get_comment'
end

prog .get_body
    class exit ""
end

prog .get_gap
    class exit ""
end
