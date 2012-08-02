(******************************************************************************)
(* Project: Unifying Theories of Programming                                  *)
(* File: utp_laws.thy                                                         *)
(* Author: Frank Zeyda, University of York (UK)                               *)
(******************************************************************************)

header {* Albegraic Laws *}

theory utp_laws
imports utp_pred utp_rel utp_subst
begin

context PRED
begin

subsection {* Variable Substitution *}

subsubsection {* Distribution Theorems *}

theorem SubstP_NotP_distr :
"\<lbrakk>p \<in> WF_PREDICATE;
 ss \<in> VAR_SUBST\<rbrakk> \<Longrightarrow>
 (\<not>p p)[ss] = \<not>p p[ss]"
apply (utp_pred_auto_tac)
done

theorem SubstP_AndP_distr :
"\<lbrakk>p1 \<in> WF_PREDICATE;
 p2 \<in> WF_PREDICATE;
 ss \<in> VAR_SUBST\<rbrakk> \<Longrightarrow>
 (p1 \<and>p p2)[ss] = p1[ss] \<and>p p2[ss]"
apply (utp_pred_auto_tac)
done

theorem SubstP_OrP_distr :
"\<lbrakk>p1 \<in> WF_PREDICATE;
 p2 \<in> WF_PREDICATE;
 ss \<in> VAR_SUBST\<rbrakk> \<Longrightarrow>
 (p1 \<or>p p2)[ss] = p1[ss] \<or>p p2[ss]"
apply (utp_pred_auto_tac)
done

theorem SubstP_ImpliesP_distr :
"\<lbrakk>p1 \<in> WF_PREDICATE;
 p2 \<in> WF_PREDICATE;
 ss \<in> VAR_SUBST\<rbrakk> \<Longrightarrow>
 (p1 \<Rightarrow>p p2)[ss] = p1[ss] \<Rightarrow>p p2[ss]"
apply (utp_pred_auto_tac)
done

theorem SubstP_IffP_distr :
"\<lbrakk>p1 \<in> WF_PREDICATE;
 p2 \<in> WF_PREDICATE;
 ss \<in> VAR_SUBST\<rbrakk> \<Longrightarrow>
 (p1 \<Leftrightarrow>p p2)[ss] = p1[ss] \<Leftrightarrow>p p2[ss]"
apply (utp_pred_auto_tac)
done

theorem SubstP_ExistsP_distr :
"\<lbrakk>p \<in> WF_PREDICATE;
 ss \<in> VAR_SUBST_ON vs1;
 vs1 \<inter> vs2 = {}\<rbrakk> \<Longrightarrow>
 (\<exists>p vs2 . p)[ss] = (\<exists>p vs2 . p[ss])"
apply (utp_pred_tac)
apply (safe)
apply (subgoal_tac "(inv ss) \<in> VAR_SUBST_ON vs1")
apply (rule_tac x = "SubstB ss b'" in bexI)
apply (subst SubstB_override_distr3 [of "(inv ss)" vs1])
apply (simp_all add: closure)
apply (subgoal_tac "(inv ss) \<in> VAR_SUBST_ON vs1")
apply (rule_tac x = "SubstB (inv ss) b'" in bexI)
apply (subst SubstB_override_distr4 [of "(inv ss)" vs1])
apply (simp_all add: closure)
done

theorem SubstP_ForallP_distr :
"\<lbrakk>p \<in> WF_PREDICATE;
 ss \<in> VAR_SUBST_ON vs1;
 vs1 \<inter> vs2 = {}\<rbrakk> \<Longrightarrow>
 (\<forall>p vs2 . p)[ss] = (\<forall>p vs2 . p[ss])"
apply (simp add: ForallP_def closure)
apply (simp add: SubstP_ExistsP_distr SubstP_NotP_distr closure)
done

theorem SubstP_ClosureP :
"\<lbrakk>p \<in> WF_PREDICATE;
 ss \<in> VAR_SUBST\<rbrakk> \<Longrightarrow>
 [p[ss]] = ([p] :: ('VALUE, 'TYPE) PREDICATE)"
apply (utp_pred_tac)
apply (safe)
apply (drule_tac x = "SubstB ss x" in bspec)
apply (simp_all add: closure)
done

subsection {* Proof Experiments *}

text {*
  The following proof illustrates how we use a mixture of algebraic laws and
  the proof strategy for predicates to proof more complex properties. For now
  the strategy alone is not powerful enough to prove the theorem by itself.
*}

theorem SubstP_invariant_taut :
"\<lbrakk>p1 \<in> WF_PREDICATE;
 p2 \<in> WF_PREDICATE;
 ss \<in> VAR_SUBST\<rbrakk> \<Longrightarrow>
 taut [p1 \<Leftrightarrow>p p2] \<Leftrightarrow>p [p1[ss] \<Leftrightarrow>p p2[ss]]"
apply (utp_pred_auto_tac)
oops

theorem SubstP_invariant_taut :
"\<lbrakk>p1 \<in> WF_PREDICATE;
 p2 \<in> WF_PREDICATE;
 ss \<in> VAR_SUBST\<rbrakk> \<Longrightarrow>
 taut [p1 \<Leftrightarrow>p p2] \<Leftrightarrow>p [p1[ss] \<Leftrightarrow>p p2[ss]]"
apply (subgoal_tac "p1[ss] \<Leftrightarrow>p p2[ss] = (p1 \<Leftrightarrow>p p2)[ss]")
apply (simp)
apply (simp add: SubstP_ClosureP closure)
apply (utp_pred_tac)
apply (simp add: SubstP_IffP_distr)
done
end
end