{smcl}
{* *! version 1.0.0  19mar2019}{...}

{viewerjumpto "Syntax" "pt_model_mt##syntax"}{...}
{viewerjumpto "Description" "pt_model_mt##description"}{...}
{viewerjumpto "Options" "pt_model_mt##options"}{...}
{viewerjumpto "Remarks" "pt_model_mt##remarks"}{...}
{viewerjumpto "Examples" "pt_model_mt##examples"}{...}



{title:Title}

{phang}
{bf:pt_model_mt} {hline 2} A post estimation command which adds lines of a model results table to an open postfile for a model estimated with a time by treatment interaction. 

{marker syntax}{...}
{title:Syntax}

{p 8 17}
{cmdab:pt_model}
{varlist}
{ifin}
{cmd:, postname(}{it:string}{cmd:)}
{cmd: sub_var(}{it:varname}{cmd:)}
[{it:options}]


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Main}
{synopt:{opt postfile(postname)}} Provide name of an open postfile.{p_end}
{synopt:{opt time_var(varname)}} The name of the variable interacting with treatment assignment.{p_end}


{syntab:Treatment indicator}
{synopt:{opt treat(varname)}} The name of a binary or categorical exposure of interest. This variable must be the first variable in the model after outcome. This will be random allocation in an RCT.{p_end}
{synopt:{opt treat_grps(numlist)}} Specify the order levels of the {cmd: treat }variable are to be reported. Default is ascending.{p_end}
{synopt:{opt compare(comparisons)}} The treatment comparisons to report, written as two arm values joined by {cmd:v}, for example {cmd:compare(2v1 3v1)}. {cmd:2v1} means arm 2 minus arm 1. Default is every pair of arms, higher value vs lower value. See {help pt_model_mt##arms:Multiple treatment arms}.{p_end}

{syntab:Subgroups}
{synopt:{opt timepoints(numlist)}} Specify the order levels of the timepoint variable should be presented. {cmd: sub_var }variable are to be reported. Default is ascending.{p_end}



{syntab:Presenting data}
{synopt:{opt t:ype(type)}}Specifies the summary statistics to be produced. {it:type} can be {cmd:cont}, {cmd:skew}, {cmd:bin}. 
	If {cmd:type()} is not specified, then {it:type} is determined by the number of unique values the variable takes. Currently categorical variables are not supported and unless variable is binary it will auto report as mean (sd).{p_end}
	For continuous variables {cmd:type(cont)}  uses mean (sd) for summaries and {cmd:type(skew)} uses median (IQR). {p_end}
{synopt:{opt positive(#)}} {cmd:positive(#)} sets the value that is considered positive for binary variables, default is {cmd:positive(1)}.{p_end}
{synopt:{opt per}}Include % after percentages in table. {p_end}

{syntab:Gaps}
{synopt:{opt gap(#)}}Add # blank rows after each variable.{p_end}

{syntab:Denominators and missing data}
{synopt:{opt n:_analysis(postion cond %)}}Include number of nonmissing observations. {it:position} must be specified with {cmd:n_analysis()}, {cmd:cond} and {cmd:%} are optional.
	  {it:position} can be {cmd:cols}, {cmd:append}, or {cmd:brackets}. 
	{cmd:cols} adds columns to the table with numbers of nonmissing observations, {cmd:append} appends the number of nonmissing observations to the variabl label, and {cmd:brackets} reports the number of nonmissing observations after the summary.
	If {cmd:(n_analysis(}{it:postion}{cmd: cond)} is set, the number of nonmissing observations will only be reported when the number of missing observations is greater than zero. 
	If {cmd:(n_analysis(}{it:postion}{cmd: %)} is set the percent of nonmissing observations will be reported as well as the count. {cmd: cond} and {cmd: %} may be used in conjuntion. {p_end}
{synopt:{opt m:issing(postion cond %)}}Include number of missing observations. {cmd:missing()} follows the same syntax as {cmd:n_analysis}.{p_end}

{syntab:Labeling rows}
{synopt:{opt su_label(position)}}Position of the summary label. {it:position } can be {cmd:append }, which appends summary label to variable label, or {cmd:col}, which includes the label in its own column.
 Default is to omit summary label.{p_end}
{synopt:{opt su_label_text(string)}}Text for summary label. Default is mean(sd) for {cmd:type(cont)}, median (IQR) for {cmd:type(skew)}, and n (%) for all other types.{p_end}
{synopt:{opt var_lab(string)}}Set row label. Default is variable label{p_end}
{synopt:{opt append_label(string)}}Append text to variable label{p_end}

{syntab:Setting decimal places}
{synopt:{opt decimal(#)}}Decimal places for any decimals presented. {cmd:su_decimal} or {cmd:miss_decimal} take precedence over {cmd:decimal}.{p_end}
{synopt:{opt su_decimal(#)}}Decimal places used when presenting summary statistics.{p_end}
{synopt:{opt est_decimal(#)}}Decimal places used when presenting estimates.{p_end}
{synopt:{opt miss_decimal(#)}}Decimal places used when presenting percent missing or percent with non missing observations.{p_end}

{syntab:Model reporting}
{synopt:{opt exp}}Expiate estimates and confidence interval bounds.{p_end}
{synopt:{opt icc}}Include an ICC. This calls estat ICC. Requires an additional ICC column in postfix.{p_end}

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:pt_model_mt} is part of the {cmd:post_table} package. The command should be run after estimating a model and can be used to build a results table for two or more treatment arms. 
The command requires a post file to have been opened with the required number of columns and the data type for each column as string. You must pass the name of the postfile to the command with postname(). 
Run after estimating a model, the command then posts lines to the post file with summary statistics for the variables in varlist and results from the model. 
It will work with most GLMs run with Stata. Exceptions are survival models, or ordinal or multinomial regression.

{marker arms}{...}
{title:Multiple treatment arms}

{pstd}
The model must include the treatment by time interaction using factor variable notation, for example {cmd:mixed y i.treat##i.time || id:}. One summary column is posted for each arm in {cmd:treat_grps()}, so the post file needs a column for each arm. 

{pstd}
{bf:Comparisons.} Each comparison is written {it:a}{cmd:v}{it:b} and is arm {it:a} minus arm {it:b} (a ratio with {cmd:exp}), using the values of {cmd:treat}. 
By default every pair of arms in {cmd:treat_grps()} is reported, higher value vs lower value, so arms 0, 1 and 2 give {cmd:1v0}, {cmd:2v0} and {cmd:2v1}. 
Use {cmd:compare()} to choose the comparisons, their direction and their order. Results do not depend on which arm is the reference arm of the model. 
Comparisons are labelled with the value labels of {cmd:treat}, for example "High dose vs Control", or with the numeric values where there is no label.

{pstd}
P-values and confidence intervals are not adjusted for multiple comparisons.

{pstd}
{bf:Table layout.} With two arms the table has a header row and one row per timepoint. With more than two arms, or when {cmd:compare()} is specified, the first row is a title and each comparison has a header row naming it, then one row per timepoint. Summaries are posted in the first block only.

{marker examples}{...}
{title:Examples}

{pstd}
Examples can be found on the {browse "https://github.com/GForb/post_table/tree/master/Examples":github page} for the package. 









