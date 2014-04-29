(******************************************************************************)
(* Project: Unifying Theories of Programming in HOL                           *)
(* File: Lattices_extra.thy                                                   *)
(* Author: Simon Foster, University of York (UK)                              *)
(******************************************************************************)

header {* Additional lattice properties *}

theory Lattices_extra
imports Main
begin

notation
  Sup ("\<Sqinter>_" [900] 900) and
  Inf ("\<Squnion>_" [900] 900) and
  sup  (infixl "\<sqinter>" 65) and
  inf  (infixl "\<squnion>" 70)

text {* Disjunctive unary functions *}

definition disjunctive ::
  "('a::lattice \<Rightarrow> 'b::lattice) \<Rightarrow> bool" where
"disjunctive F \<longleftrightarrow> (\<forall> P Q. (F (P \<sqinter> Q)) = ((F P) \<sqinter> (F Q)))"

lemma disjunctiveI [intro]:
  "\<lbrakk> \<And> P Q. (F (P \<sqinter> Q)) = ((F P) \<sqinter> (F Q)) \<rbrakk> \<Longrightarrow>
   disjunctive F"
  by (simp add:disjunctive_def)

lemma disjunctiveE [elim]:
  "\<lbrakk> disjunctive F; \<lbrakk> \<And> P Q. (F (P \<sqinter> Q)) = ((F P) \<sqinter> (F Q)) \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (simp add:disjunctive_def)

text {* Disjunctive operators are monotone *}

lemma disjunctive_mono:
  assumes "disjunctive F"
  shows "mono F"
proof
  fix x y :: 'a
  assume xley: "x \<le> y"

  have "F x \<le> F y \<longleftrightarrow> ((F x \<sqinter> F y) = F y)"
    by (metis le_iff_sup)

  also from assms have "... \<longleftrightarrow> (F (x \<sqinter> y) = F y)"
    by (auto)

  also from assms have "..."
    by (metis sup_absorb2 xley)
    
  finally show "F x \<le> F y" by simp
qed

context order
begin

definition mono2 :: "('a \<Rightarrow> 'b::order \<Rightarrow> 'c::order) \<Rightarrow> bool" where
"mono2 F \<equiv> \<forall> x1 x2 y1 y2. (x1 \<le> y1) \<and> (x2 \<le> y2) \<longrightarrow> F x1 x2 \<le> F y1 y2"

lemma mono2I [intro]:
  fixes f :: "'a \<Rightarrow> 'b::order \<Rightarrow> 'c::order"
  shows "(\<And>x1 x2 y1 y2. \<lbrakk> x1 \<le> y1; x2 \<le> y2 \<rbrakk> \<Longrightarrow> f x1 x2 \<le> f y1 y2) \<Longrightarrow> mono2 f"
  unfolding mono2_def by auto

lemma mono2E [elim]:
  fixes f :: "'a \<Rightarrow> 'b::order \<Rightarrow> 'c::order"
  shows "\<lbrakk> mono2 f; (\<And>x1 x2 y1 y2. \<lbrakk> x1 \<le> y1; x2 \<le> y2 \<rbrakk> \<Longrightarrow> f x1 x2 \<le> f y1 y2) \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  unfolding mono2_def by auto

end

definition disjunctive2 :: "('a::lattice \<Rightarrow> 'b::lattice \<Rightarrow> 'c::lattice) \<Rightarrow> bool" where
"disjunctive2 F = (\<forall> x1 x2 y1 y2. F (x1 \<sqinter> y1) (x2 \<sqinter> y2) = (F x1 x2) \<sqinter> (F x1 y2) \<sqinter> (F y1 x2) \<sqinter> (F y1 y2))"

lemma disjunctive2I [intro]:
  "\<lbrakk> \<And> x1 x2 y1 y2. (F (x1 \<sqinter> y1) (x2 \<sqinter> y2) = (F x1 x2) \<sqinter> (F x1 y2) \<sqinter> (F y1 x2) \<sqinter> (F y1 y2)) \<rbrakk> \<Longrightarrow>
   disjunctive2 F"
  by (simp add:disjunctive2_def)

lemma disjunctive2E [elim]:
  "\<lbrakk> disjunctive2 F
   ; \<lbrakk> \<And> x1 x2 y1 y2. (F (x1 \<sqinter> y1) (x2 \<sqinter> y2) = (F x1 x2) \<sqinter> (F x1 y2) \<sqinter> (F y1 x2) \<sqinter> (F y1 y2)) \<rbrakk> \<Longrightarrow> P \<rbrakk> \<Longrightarrow> P"
  by (simp add:disjunctive2_def)

lemma disjunctive2_mono2:
  assumes "disjunctive2 F"
  shows "mono2 F"
proof
  fix x1 y1 :: 'a and x2 y2 :: 'b

  assume x1ley1: "x1 \<le> y1" and x2ley2: "x2 \<le> y2"

  have "F x1 x2 \<le> F y1 y2 \<longleftrightarrow> ((F x1 x2 \<sqinter> F y1 y2) = F y1 y2)"
    by (metis le_iff_sup)

  also from assms have "... \<longleftrightarrow> (F (x1 \<sqinter> y1) (x2 \<sqinter> y2) = F y1 y2)"
    apply (auto)
    apply (metis le_iff_sup x1ley1 x2ley2)
    apply (erule disjunctive2E)
    apply (metis disjunctive2E sup_absorb1 sup_commute sup_ge1)
  done

  also from assms have "..."
    by (metis sup_absorb2 x1ley1 x2ley2)
    
  finally show "F x1 x2 \<le> F y1 y2" by simp
qed

end