{smcl}
{* *! version 1.0.0  19mar2019}{...}

{viewerjumpto "Syntax" "pt_base##syntax"}{...}
{viewerjumpto "Description" "pt_base##description"}{...}
{viewerjumpto "Options" "pt_base##options"}{...}
{viewerjumpto "Remarks" "pt_base##remarks"}{...}
{viewerjumpto "Examples" "pt_base##examples"}{...}



{title:Title}

{phang}
{bf:pt_sum} {hline 2} Adds summary statistics of continuous variables to an open postfile.

{marker syntax}{...}
{title:Syntax}

{p 8 17}
{cmdab:pt_sum} {varlist} {ifin}
{cmd:, postname(}{it:string}{cmd:)}
{cmd: stats(}{it:string}{cmd:)}
[{it:options}]


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt postfile(postname)}} Provide name of an open postfile.{p_end}
{synopt:{opt stats(statname [...])}} Statistics to be reported. {it:statname} can be: {cmd:N}, {cmd:mean_sd}; {cmd:median_iqr}, {cmd: range}.{p_end}

{syntab:Over}
{synopt:{opt over(varname)}}Summarise variables over {it:varname}.{p_end}
{synopt:{opt over_grps(numlist)}}Specify the order levels of the {cmd:over }variable are to be reported. Default is ascending.{p_end}
{synopt:{opt overall(position)}}Include overall summary when over is specified. {it:position } can be {cmd:first }or {cmd:last}.{p_end}



{syntab:Gaps}
{synopt:{opt gap(#)}}Add # blank rows after each variable.{p_end}
{synopt:{opt gap_end(#)}}Add # blank rows after all variables have been reported.{p_end}

{syntab:Ordering columns}
{synopt:{opt order(order)}}The option {cmd:order(group_sum)} can be used to group statistics by over variable first, then summary statistic. The default is for columns to be grouped first by summary statistics then by the over variable. 
	 {p_end}

{syntab:Labeling rows}

{synopt:{opt var_lab(string)}}Set row label. Default is variable label.{p_end}
{synopt:{opt append_label(string)}}Append text to variable label.{p_end}

{syntab:Setting decimal places}
{synopt:{opt decimal(#)}}Decimal places for any decimals presented. {cmd:med_iqr_decimal} or {cmd:range_decimal} take precedence over {cmd:decimal}.{p_end}
{synopt:{opt med_iqr_decimal(#)}}Decimal places used when presenting medians and IQR.{p_end}
{synopt:{opt range_decimal(#)}}Decimal places used when presenting ranges.{p_end}


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









