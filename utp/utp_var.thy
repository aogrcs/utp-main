section {* UTP variables *}

theory utp_var
imports
  "../contrib/Kleene_Algebra/Quantales" 
  "../contrib/HOL-Algebra2/Complete_Lattice"
  "../contrib/HOL-Algebra2/Galois_Connection"
  "../utils/cardinals"
  "../utils/Continuum"
  "../utils/finite_bijection"
  "../utils/interp"
  "../utils/Lenses"
  "../utils/Positive_New"
  "../utils/Profiling"
  "../utils/ttrace"
  "../utils/Library_extra/Pfun"
  "../utils/Library_extra/Ffun"
  "../utils/Library_extra/Derivative_extra"
  "../utils/Library_extra/List_lexord_alt"
  "../utils/Library_extra/Monoid_extra"
  "~~/src/HOL/Library/Prefix_Order"
  "~~/src/HOL/Library/Char_ord"
  "~~/src/HOL/Library/Adhoc_Overloading"
  "~~/src/HOL/Library/Monad_Syntax"
  "~~/src/HOL/Library/Countable"
  "~~/src/HOL/Eisbach/Eisbach"
  utp_parser_utils
begin

no_notation inner (infix "\<bullet>" 70)

no_notation le (infixl "\<sqsubseteq>\<index>" 50)

no_notation
  Set.member  ("op :") and
  Set.member  ("(_/ : _)" [51, 51] 50)

declare fst_vwb_lens [simp]
declare snd_vwb_lens [simp]
declare lens_indep_left_comp [simp]
declare comp_vwb_lens [simp]
declare lens_indep_left_ext [simp]
declare lens_indep_right_ext [simp]

text {* This theory describes the foundational structure of UTP variables, upon which the rest
        of our model rests. We start by defining alphabets, which following~\cite{Feliachi2010,Feliachi2012} 
        in this shallow model are simply represented as types, though by convention usually a record 
        type where each field corresponds to a variable. *}

type_synonym '\<alpha> "alphabet"  = "'\<alpha>"

text {* UTP variables carry two type parameters, $'a$ that corresponds to the variable's type
        and $'\alpha$ that corresponds to alphabet of which the variable is a type. There
        is a thus a strong link between alphabets and variables in this model. Variable are characterized 
        by two functions, \emph{var-lookup} and \emph{var-update}, that respectively lookup and update 
        the variable's value in some alphabetised state space. These functions can readily be extracted
        from an Isabelle record type.
*}

type_synonym ('a, '\<alpha>) uvar = "('a, '\<alpha>) lens"

text {* The $VAR$ function~\cite{Feliachi2010} is a syntactic translations that allows to retrieve a variable given its 
        name, assuming the variable is a field in a record. *}

syntax "_VAR" :: "id \<Rightarrow> ('a, 'r) uvar"  ("VAR _")
translations "VAR x" => "FLDLENS x"

 text {* We also define some lifting functions for variables to create input and output variables.
        These simply lift the alphabet to a tuple type since relations will ultimately be defined
        to a tuple alphabet. *}

definition in_var :: "('a, '\<alpha>) uvar \<Rightarrow> ('a, '\<alpha> \<times> '\<beta>) uvar" where
[lens_defs]: "in_var x = x ;\<^sub>L fst\<^sub>L"

definition out_var :: "('a, '\<beta>) uvar \<Rightarrow> ('a, '\<alpha> \<times> '\<beta>) uvar" where
[lens_defs]: "out_var x = x ;\<^sub>L snd\<^sub>L"

definition pr_var :: "('a, '\<beta>) uvar \<Rightarrow> ('a, '\<beta>) uvar" where
[simp]: "pr_var x = x"

lemma in_var_semi_uvar [simp]:
  "mwb_lens x \<Longrightarrow> mwb_lens (in_var x)"
  by (simp add: comp_mwb_lens in_var_def)

lemma in_var_uvar [simp]:
  "vwb_lens x \<Longrightarrow> vwb_lens (in_var x)"
  by (simp add: in_var_def)

lemma out_var_semi_uvar [simp]:
  "mwb_lens x \<Longrightarrow> mwb_lens (out_var x)"
  by (simp add: comp_mwb_lens out_var_def)

lemma out_var_uvar [simp]:
  "vwb_lens x \<Longrightarrow> vwb_lens (out_var x)"
  by (simp add: out_var_def)

lemma in_out_indep [simp]:
  "in_var x \<bowtie> out_var y"
  by (simp add: lens_indep_def in_var_def out_var_def fst_lens_def snd_lens_def lens_comp_def)

lemma out_in_indep [simp]:
  "out_var x \<bowtie> in_var y"
  by (simp add: lens_indep_def in_var_def out_var_def fst_lens_def snd_lens_def lens_comp_def)

lemma in_var_indep [simp]:
  "x \<bowtie> y \<Longrightarrow> in_var x \<bowtie> in_var y"
  by (simp add: in_var_def out_var_def)

lemma out_var_indep [simp]:
  "x \<bowtie> y \<Longrightarrow> out_var x \<bowtie> out_var y"
  by (simp add: out_var_def)

text {* We also define some lookup abstraction simplifications. *}

lemma var_lookup_in [simp]: "lens_get (in_var x) (A, A') = lens_get x A"
  by (simp add: in_var_def fst_lens_def lens_comp_def)

lemma var_lookup_out [simp]: "lens_get (out_var x) (A, A') = lens_get x A'"
  by (simp add: out_var_def snd_lens_def lens_comp_def)

lemma var_update_in [simp]: "lens_put (in_var x) (A, A') v = (lens_put x A v, A')"
  by (simp add: in_var_def fst_lens_def lens_comp_def)

lemma var_update_out [simp]: "lens_put (out_var x) (A, A') v = (A, lens_put x A' v)"
  by (simp add: out_var_def snd_lens_def lens_comp_def)

text {* Variables can also be used to effectively define sets of variables. Here we define the
        the universal alphabet ($\Sigma$) to be a variable with identity for both the lookup
        and update functions. Effectively this is just a function directly on the alphabet type. *}

abbreviation (input) univ_alpha :: "('\<alpha>, '\<alpha>) uvar" ("\<Sigma>") where
"univ_alpha \<equiv> 1\<^sub>L"

(*
  Nonterminals:
    svid: is an identifier soely used for variables
    svar: is a potentially decorated variable (but does not need to be?!)
    salpha: is to construct alphabets (variable sets). This can only be done
    through lense composition due to typing restrictions.
*)

nonterminal svid and svar and salpha

syntax
  "_salphaid"    :: "id \<Rightarrow> salpha" ("_" [998] 998)
  "_salphavar"   :: "svar \<Rightarrow> salpha" ("_" [998] 998)
(*  "_salphacomp"  :: "salpha \<Rightarrow> salpha \<Rightarrow> salpha" (infixr "," 75) *)
  "_salphacomp"  :: "salpha \<Rightarrow> salpha \<Rightarrow> salpha" (infixr ";" 75)
  "_svid"        :: "id \<Rightarrow> svid" ("_" [999] 999)
  "_svid_alpha"  :: "svid" ("\<Sigma>")
  "_svid_empty"  :: "svid" ("\<emptyset>")
  "_svid_dot"    :: "svid \<Rightarrow> svid \<Rightarrow> svid" ("_:_" [999,998] 999)
  "_spvar"       :: "svid \<Rightarrow> svar" ("&_" [998] 998)
  "_sinvar"      :: "svid \<Rightarrow> svar" ("$_" [998] 998)
  "_soutvar"     :: "svid \<Rightarrow> svar" ("$_\<acute>" [998] 998)

(*
  The functions below turn a representation of a variable (type 'v) including
  its name and type. And 'e is typically some lense type. So the functions
  below bridge between then model/encoding of the variable and its interpretation
  as a lense in order to integrate it into the general lense-based framework.
  Overriding the below is all we need to make use of any kind of variables in
  terms of interfacing it with the system.
*)

consts
  svar :: "'v \<Rightarrow> 'e"
  ivar :: "'v \<Rightarrow> 'e"
  ovar :: "'v \<Rightarrow> 'e"

adhoc_overloading
  svar pr_var and ivar in_var and ovar out_var

translations
  "_salphaid x" => "x"
  "_salphacomp x y" => "x +\<^sub>L y"
  "_salphavar x" => "x"
  "_svid_alpha" == "\<Sigma>"
  "_svid_empty" == "0\<^sub>L"
  "_svid_dot x y" => "y ;\<^sub>L x"
  "_svid x" => "x"
  "_sinvar (_svid_dot x y)" <= "CONST ivar (CONST lens_comp y x)"
  "_soutvar (_svid_dot x y)" <= "CONST ovar (CONST lens_comp y x)"
  "_spvar x" == "CONST svar x"
  "_sinvar x" == "CONST ivar x"
  "_soutvar x" == "CONST ovar x"

text {* Syntactic function to construct a uvar type given a return type *}

syntax
  "_uvar_ty"      :: "type \<Rightarrow> type \<Rightarrow> type"

parse_translation {*
let
  fun uvar_ty_tr [ty] = Syntax.const @{type_syntax uvar} $ ty $ Syntax.const @{type_syntax dummy}
    | uvar_ty_tr ts = raise TERM ("uvar_ty_tr", ts);
in [(@{syntax_const "_uvar_ty"}, K uvar_ty_tr)] end
*}

end