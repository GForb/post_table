{smcl}
{* *! version 1.0.0  19mar2019}{...}

{viewerjumpto "Syntax" "pt_subgroup##syntax"}{...}
{viewerjumpto "Description" "pt_subgroup##description"}{...}
{viewerjumpto "Options" "pt_subgroup##options"}{...}
{viewerjumpto "Remarks" "pt_subgroup##remarks"}{...}
{viewerjumpto "Examples" "pt_subgroup##examples"}{...}



{title:Title}

{phang}
{bf:pt_subgroup} {hline 2} A post estimation command which adds lines of a model results table to an open postfile for a model which includes an interaction term. 

{marker syntax}{...}
{title:Syntax}

{p 8 17}
{cmdab:pt_subgroup}
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
{synopt:{opt sub_var(varname)}} The name of the variable interacting with treatment assignment.{p_end}


{syntab:Treatment indicator}
{synopt:{opt treat(varname)}} The name of a binary or categorical exposure of interest. This variable must be the first variable in the model after outcome. This will be random allocation in an RCT.{p_end}
{synopt:{opt treat_grps(numlist)}} Specify the order levels of the {cmd: treat }variable are to be reported. Default is ascending.{p_end}
{synopt:{opt prim_treat(integer)}} Non-reference group for {cmd: treat} used in statistical test for interaction. The interaction p-value is a joint test of all interaction terms between this group and {cmd: sub_var}. If ommited defaults to maximum value which matches Stata default behaviour {p_end}

{syntab:Subgroups}
{synopt:{opt sub_grps(numlist)}} Specify the order levels of the {cmd: sub_var }variable are to be reported. Default is ascending.{p_end}



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
{synopt:{opt int_test_false}}Report p-values for each level of the subgroup variable rather than the global interaction test.

{synopt:{opt use_outcome_label}}Label the rows with the label from the outcome variable. Default is to use subgroup variable.

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:pt_subgroup} is part of the {cmd:post_table} package. The command should be run after estimating a model with a treatment by subgroup interaction and can be used to build a results table. Treatment and subgroup variables can each have two or more levels; see {help pt_subgroup##remarks:below}. 
The command requires a post file to have been opened with the required number of columns and the data type for each column as string. You must pass the name of the postfile to the command with postname(). 
Run after estimating a model, the command then posts lines to the post file with summary statistics for the variables in varlist and results from the model. 
It will work with most GLMs run with Stata. Exceptions are survival models, or ordinal or multinomial regression.

{marker remarks}{...}
{title:Multiple treatment arms and subgroup levels}

{pstd}
The model must include the treatment by subgroup interaction using factor variable notation, for example {cmd:regress y i.treat##i.subgroup}.

{pstd}
{bf:Treatment arms.} One summary column is posted for each arm in {cmd:treat_grps()}, so the post file needs a column for each arm. 
Estimates are posted for one comparison only: {cmd:prim_treat()} against the reference arm of the model. 
To compare each arm with the reference, run {cmd:pt_subgroup} once per arm, setting {cmd:prim_treat()} each time. Each run posts its own set of rows, and the summary columns are repeated. Use {cmd:var_lab()} to name the comparison on each set of rows, as the header row does not show it by default. 
{cmd:prim_treat()} defaults to the highest value in {cmd:treat_grps()}. 
The command stops with an error if {cmd:prim_treat()} is the reference arm of the model. This includes the default when the highest arm is the reference, for example after fitting {cmd:ib2.treat} with arms 0, 1 and 2.

{pstd}
{bf:Subgroup levels.} One row is posted for each level in {cmd:sub_grps()}, giving the effect of {cmd:prim_treat()} against the reference arm within that level. {cmd:sub_var} must have value labels.

{pstd}
{bf:Interaction p-value.} The p-value on the header row is a joint test of all interaction terms between {cmd:prim_treat()} and {cmd:sub_var}, with degrees of freedom equal to the number of subgroup levels minus one. 
It does not test the other treatment arms, and it does not depend on which subgroup level is the reference. 
It covers every subgroup level in the model, even if {cmd:sub_grps()} reports only some of them.

{marker examples}{...}
{title:Examples}

{pstd}
Examples can be found on the {browse "https://github.com/GForb/post_table/tree/master/Examples":github page} for the package. 









