(******************************************************************************)
(* Title: utp/generic/utp_alphabet.thy                                        *)
(* Author: Frank Zeyda, University of York                                    *)
(******************************************************************************)
theory utp_alphabet
imports utp_var
begin

section {* Alphabets *}

types 'TYPE ALPHABET = "'TYPE VAR set"

context VAR
begin
subsection {* Well-formed Alphabets *}

definition WF_ALPHABET :: "'TYPE ALPHABET set" where
"WF_ALPHABET = {a . finite a}"

subsection {* Alphabet Operators *}

definition in_alphabet ::
  "'TYPE ALPHABET \<Rightarrow>
   'TYPE ALPHABET" ("in") where
"in a = (a \<inter> UNDASHED)"

definition out_alphabet ::
  "'TYPE ALPHABET \<Rightarrow>
   'TYPE ALPHABET" ("out") where
"out a = (a \<inter> DASHED)"

subsection {* Restrictions *}

definition COMPOSABLE ::
  "'TYPE ALPHABET \<Rightarrow>
   'TYPE ALPHABET \<Rightarrow> bool" where
"\<lbrakk>a1 \<in> WF_ALPHABET;
 a2 \<in> WF_ALPHABET\<rbrakk> \<Longrightarrow>
 COMPOSABLE a1 a2 \<longleftrightarrow> (out a1) = dash ` (in a2)"
end
end