(******************************************************************************)
(* Title: utp/models/utp_std_pred.thy                                         *)
(* Author: Frank Zeyda, University of York                                    *)
(******************************************************************************)
theory utp_std_pred
imports "../GLOBAL" "../generic/utp_generic" utp_default_value
begin

section {* Standard Predicates *}

text {* Standard predicates are typed using composite default values. *}

types STD_VALUE = "DEFAULT_VALUE COMPOSITE_VALUE"
types STD_TYPE = "DEFAULT_TYPE COMPOSITE_TYPE"

locale STD_PRED =
  COMPOSITE_VALUE "basic_type_rel" +
  TYPED_PRED "lift_type_rel_composite basic_type_rel"
for basic_type_rel :: "'BASIC_VALUE :: BASIC_SORT \<Rightarrow> 'BASIC_TYPE \<Rightarrow> bool"

interpretation STD :
  STD_PRED "default_type_rel"
apply (simp add: STD_PRED_def)
apply (auto)
done

subsection {* Semantic Domains *}

definition STD_VALUE [simp] :
"STD_VALUE = STD.universe"

definition STD_ALPHABET [simp] :
"STD_ALPHABET \<equiv> STD.WF_ALPHABET"

definition STD_BINDING [simp] :
"STD_BINDING \<equiv> WT_BINDING default_type_rel"

definition STD_BINDING_SET [simp] :
"STD_BINDING_SET \<equiv> STD.WF_BINDING_SET"

definition STD_BINDING_FUN [simp] :
"STD_BINDING_FUN \<equiv> STD.WF_BINDING_FUN"

definition STD_PREDICATE [simp] :
"STD_PREDICATE \<equiv> STD.WF_ALPHA_PREDICATE"

definition STD_FUNCTION [simp] :
"STD_FUNCTION \<equiv> STD.WF_ALPHA_FUNCTION"

subsection {* Global Syntax *}

subsubsection {* Value Syntax *}

defs STD_type_rel [simp] :
"GLOBAL.type_rel \<equiv> lift_type_rel_composite default_type_rel"

defs STD_set_type_rel [simp] :
"GLOBAL.set_type_rel \<equiv> STD.set_type_rel"

subsubsection {* Predicate Syntax *}

defs STD_alphabet [simp] :
"GLOBAL.alphabet \<equiv> STD.alphabet"

defs STD_bindings [simp] :
"GLOBAL.bindings \<equiv> STD.bindings"

defs STD_binding_equiv [simp] :
"GLOBAL.binding_equiv \<equiv> STD.binding_equiv"

defs STD_LiftP [simp] :
"GLOBAL.LiftP \<equiv> STD.LiftP"

defs STD_TrueP [simp] :
"GLOBAL.TrueP \<equiv> STD.TrueP"

defs STD_FalseP [simp] :
"GLOBAL.FalseP \<equiv> STD.FalseP"

defs STD_TRUE [simp] :
"GLOBAL.TRUE \<equiv> STD.TRUE"

defs STD_FALSE [simp] :
"GLOBAL.FALSE \<equiv> STD.FALSE"

defs STD_ExtP [simp] :
"GLOBAL.ExtP \<equiv> STD.ExtP"

defs STD_ResP [simp] :
"GLOBAL.ResP \<equiv> STD.ResP"

defs STD_NotP [simp] :
"GLOBAL.NotP \<equiv> STD.NotP"

defs STD_AndP [simp] :
"GLOBAL.AndP \<equiv> STD.AndP"

defs STD_OrP [simp] :
"GLOBAL.OrP \<equiv> STD.OrP"

defs STD_ImpliesP [simp] :
"GLOBAL.ImpliesP \<equiv> STD.ImpliesP"

defs STD_IffP [simp] :
"GLOBAL.IffP \<equiv> STD.IffP"

defs STD_ExistsResP [simp] :
"GLOBAL.ExistsResP \<equiv> STD.ExistsResP"

defs STD_ForallResP [simp] :
"GLOBAL.ForallResP \<equiv> STD.ForallResP"

defs STD_ExistsP [simp] :
"GLOBAL.ExistsP \<equiv> STD.ExistsP"

defs STD_ForallExtP [simp] :
"GLOBAL.ForallP \<equiv> STD.ForallP"

defs STD_ClosureP [simp] :
"GLOBAL.ClosureP \<equiv> STD.ClosureP"

defs STD_RefP [simp] :
"GLOBAL.RefP \<equiv> STD.RefP"

defs STD_Tautology [simp] :
"GLOBAL.Tautology \<equiv> STD.Tautology"

defs STD_Contradiction [simp] :
"GLOBAL.Contradiction \<equiv> STD.Contradiction"

defs STD_Contingency [simp] :
"GLOBAL.Contingency \<equiv> STD.Contingency"

defs STD_Refinement [simp] :
"GLOBAL.Refinement \<equiv> STD.Refinement"

subsection {* Proof Experiments *}

text {* Value Proofs *}

theorem
"STD.MkInt(1) +v STD.MkInt(2) = STD.MkInt(3)"
apply (simp)
done

theorem
"STD.MkInt(1) \<in>v STD.MkSet({STD.MkInt(1), STD.MkInt(2)})"
apply (simp)
done

theorem
"STD.MkInt(3) \<in>v
 STD.MkSet({STD.MkInt(1)}) \<union>v STD.MkSet({STD.MkInt(1) +v STD.MkInt(2)})"
apply (simp)
done

text {* Predicate Proofs *}

theorem
"\<lbrakk>p1 \<in> STD_PREDICATE;
 p2 \<in> STD_PREDICATE;
 p3 \<in> STD_PREDICATE\<rbrakk> \<Longrightarrow>
 p1 \<and>p (p2 \<and>p p3) = (p1 \<and>p p2) \<and>p p3"
apply (utp_pred_eq_tac)
apply (auto)
done

theorem
"\<lbrakk>p1 \<in> STD_PREDICATE;
 p2 \<in> STD_PREDICATE\<rbrakk> \<Longrightarrow>
 taut p1 \<and>p p2 \<Rightarrow>p p1"
apply (utp_pred_taut_tac)
done

theorem
"\<lbrakk>p1 \<in> STD_PREDICATE;
 p2 \<in> STD_PREDICATE;
 \<alpha> p1 = \<alpha> p2\<rbrakk> \<Longrightarrow>
 p1 \<or>p p2 \<sqsubseteq> p1"
apply (simp)
apply (utp_pred_taut_tac)
done
end