{smcl}
{* *! version 1.0.0  19mar2019}{...}

{viewerjumpto "Syntax" "pt_base##syntax"}{...}
{viewerjumpto "Description" "pt_base##description"}{...}
{viewerjumpto "Options" "pt_base##options"}{...}
{viewerjumpto "Remarks" "pt_base##remarks"}{...}
{viewerjumpto "Examples" "pt_base##examples"}{...}



{title:Title}

{phang}
{bf:pt_base} {hline 2} Adds lines of a baseline table to an open postfile.

{marker syntax}{...}
{title:Syntax}

{p 8 17}
{cmdab:pt_base}
{varlist}
{ifin}
{cmd:, postname(}{it:string}{cmd:)}
[{it:options}]


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Main}
{synopt:{opt postfile(postname)}} Provide name of an open postfile.{p_end}

{syntab:Over levels of a variable}
{synopt:{opt over(varname)}}Summarise variables over {it:varname}{p_end}
{synopt:{opt over_grps(numlist)}}Specify the order levels of the {cmd:over }variable are to be reported. Default is ascending{p_end}
{synopt:{opt overall(position)}}Include overall summary when over is specified. {it:position } can be {cmd:first }or {cmd:last}.{p_end}

{syntab:Presenting data}
{synopt:{opt t:ype(type)}}Specifies the summary statistics to be produced. {it:type} can be {cmd:cont}, {cmd:skew}, {cmd:bin}, {cmd:cat} or {cmd:misstable}. 
	If {cmd:type()} is not specified, then {it:type} is determined by the number of unique values the variable takes.
	 A variable with 10 or more unique values will be considered {cmd:type(cont)}.
	For continuous variables {cmd:type(cont)}  uses mean (sd) for summaries and {cmd:type(skew)} uses median (IQR). {cmd:type(misstable)} produces a table sumamrising missing values. {p_end}
{synopt:{opt positive(#)}} {cmd:positive(#)} sets the value that is considered positive for binary variables, default is {cmd:positive(1)}.{p_end}
{synopt:{opt per}}Include %	 after percentages in table. {p_end}
{synopt:{opt count_only}}Do not report percentages for catagorical and binary variables.{p_end}

{syntab:Catagprical variables}
{synopt:{opt cat_levels(numlist)}}Specify the order levels of a catagorical variable are to be reported. If a number is included in {cmd:cat_levels()} that does not appear in the dataset a row of zeros will be added to the table.{p_end}
{synopt:{opt cat_tabs(#)}}Change the number of tabs the levels of a catagorical variables are indented by.{p_end}
{synopt:{opt cat_col}}Include levels of a catagorical variable in their own column.{p_end}

{syntab:Gaps}
{synopt:{opt gap(#)}}Add # blank rows after each variable.{p_end}
{synopt:{opt gap_end(#)}}Add # blank rows after all variables have been reported.{p_end}

{syntab:Denominators and missing data}
{synopt:{opt n:_analysis(postion cond %)}}Include number of nonmissing observations. {it:position} must be specified with {cmd:n_analysis()}, {cmd:cond} and {cmd:%} are optional.
	  {it:position} can be {cmd:cols}, {cmd:append}, or {cmd:brackets}. 
	{cmd:cols} adds columns to the table with numbers of nonmissing observations, {cmd:append} appends the number of nonmissing observations to the variabl label, and {cmd:brackets} reports the number of nonmissing observations after the summary.
	If {cmd:(n_analysis(}{it:postion}{cmd: cond)} is set, the number of nonmissing observations will only be reported when the number of missing observations is greater than zero. 
	If {cmd:(n_analysis(}{it:postion}{cmd: %)} is set the percent of nonmissing observations will be reported as well as the count. {cmd: cond} and {cmd: %} may be used in conjuntion. {p_end}
{synopt:{opt m:issing(postion cond %)}}Include number of missing observations. {cmd:missing()} follows the same syntax as {cmd:n_analysis}.{p_end}

{syntab:Ordering columns}
{synopt:{opt order(order)}}The option {cmd:order()} can be used when {cmd:n_analysis(cols)} or {cmd:missing(cols)} is specified. {it:order } can be {cmd:group_over} or {cmd:group_sum}. If {cmd:group_over} is specified then columns will be grouped first by levels of the over variable, 
	then by whether a summary or missing/nonmissing data count is reported. 
	Setting {cmd:group_sum} groups columns first by whether they are summaries or missing/nonmissing counts, then by levels of the over variable. 
	The default is {cmd:order(group_sum)}  {p_end}
{synopt:{opt sum_cols_first}}The option {cmd:sum_cols_first} can be used when {cmd:n_analysis(cols)} or {cmd:missing(cols} is specified. {cmd:sum_cols_first} places columns containing summaries before columns reporting number of missing or nonmissing observations{p_end}

{syntab:Labeling rows}
{synopt:{opt su_label(position)}}Position of the summary label. {it:position } can be {cmd:append }, which appends summary label to variable label, or {cmd:col}, which includes the label in its own column.
 Default is to omit summary label.{p_end}
{synopt:{opt su_label_text(string)}}Text for summary label. Default is mean(sd) for {cmd:type(cont)}, median (IQR) for {cmd:type(skew)}, and n (%) for all other types.{p_end}
{synopt:{opt var_lab(string)}}Set row label. Default is variable label{p_end}
{synopt:{opt append_label(string)}}Append text to variable label{p_end}

{syntab:Setting decimal places}
{synopt:{opt decimal(#)}}Decimal places for any decimals presented. {cmd:su_decimal} or {cmd:miss_decimal} take precedence over {cmd:decimal}.{p_end}
{synopt:{opt su_decimal(#)}}Decimal places used when presenting summary statistics.{p_end}
{synopt:{opt miss_decimal(#)}}Decimal places used when presenting percent missing or percent with non missing observations.{p_end}


{syntab:Comments}
{synopt:{opt comment(comment)}}Adds a cell containing {it:comment} in the final column. If a comment is included for another row in the table specifying {cmd:comment(no comment)} adds an empty comment cell. {p_end}

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:pt_base} is part of the {cmd:post_table} package. The command can be used to build a baseline table, or other table of summary statistics. 
The command requires a post file to have been opened with the required number of columns and the data type for each column as string. You must pass the name of the postfile to the command with postname(). 
The command then posts lines to the post file with summary statistics for the variables in varlist. 
All variables must be numeric; binary or categorical variable must have their values encoded as numbers. If variables and values are labeled the command used labels to name rows in the table by default.



{marker examples}{...}
{title:Examples}

{pstd}
Examples can be found on the {browse "https://github.com/GForb/post_table/tree/master/Examples":github page} for the package. 
The document {browse "https://github.com/GForb/post_table/tree/master/Examples/all_option_examples.do":pt_base_comprehensive_examples.pdf} includes code and the corresponding output for all options and is intended as a comprehensive guide.









