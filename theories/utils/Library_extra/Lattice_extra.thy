theory Lattice_extra
imports "~~/src/HOL/Algebra/Lattice"
begin

context weak_partial_order
begin

definition Mono :: "('a \<Rightarrow> 'a) \<Rightarrow> bool" where
"Mono f \<longleftrightarrow> (\<forall>x\<in>carrier L. \<forall>y\<in>carrier L. x \<sqsubseteq> y \<longrightarrow> f x \<sqsubseteq> f y)"

lemma MonoI [intro?]:
  fixes f :: "'a \<Rightarrow> 'a"
  assumes "(\<And>x y. \<lbrakk> x \<in> carrier L; y \<in> carrier L; x \<sqsubseteq> y \<rbrakk> \<Longrightarrow> f x \<sqsubseteq> f y)"
  shows "Mono f"
  by (metis assms Mono_def)

end

locale weak_partial_order_bottom = weak_partial_order L for L (structure) +
  assumes bottom_exists: "\<exists> x. least L x (carrier L)"
begin

lemma bottom_least: "least L \<bottom> (carrier L)"
proof -
  obtain x where "least L x (carrier L)"
    by (metis bottom_exists)

  thus ?thesis
    apply (simp add:bottom_def inf_def)
    apply (rule_tac someI2[of _ "x"])
    apply (rule greatest_LowerI)
    apply (auto simp add:least_def assms)
    apply (metis assms greatest_Lower_below order_refl)
  done
qed

lemma bottom_closed:
  "\<bottom> \<in> carrier L"
  by (metis bottom_least least_mem)

lemma bottom_lower:
  "x \<in> carrier L \<Longrightarrow> \<bottom> \<sqsubseteq> x"
  by (metis bottom_least least_le)

end

locale weak_partial_order_top = weak_partial_order L for L (structure) +
  assumes top_exists: "\<exists> x. greatest L x (carrier L)"
begin

lemma top_greatest: "greatest L \<top> (carrier L)"
proof -
  obtain x where "greatest L x (carrier L)"
    by (metis top_exists)

  thus ?thesis
    apply (simp add:top_def sup_def)
    apply (rule_tac someI2[of _ "x"])
    apply (rule least_UpperI)
    apply (auto simp add:greatest_def assms)
    apply (metis least_Upper_above order_refl)
  done
qed

lemma top_closed:
  "\<top> \<in> carrier L"
  by (metis greatest_mem top_greatest)

lemma top_lower:
  "x \<in> carrier L \<Longrightarrow> x \<sqsubseteq> \<top>"
  by (metis greatest_le top_greatest)

end

locale weak_bounded_lattice = weak_lattice + weak_partial_order_bottom + weak_partial_order_top
begin

lemma bottom_meet: "x \<in> carrier L \<Longrightarrow> \<bottom> \<sqinter> x .= \<bottom>"
  by (metis bottom_least least_def meet_closed meet_left weak_le_antisym)

lemma bottom_join: "x \<in> carrier L \<Longrightarrow> \<bottom> \<squnion> x .= x"
  by (metis bottom_least join_closed join_le join_right le_refl least_def weak_le_antisym)

lemma top_join: "x \<in> carrier L \<Longrightarrow> \<top> \<squnion> x .= \<top>"
  by (metis join_closed join_left top_closed top_lower weak_le_antisym)

lemma top_meet: "x \<in> carrier L \<Longrightarrow> \<top> \<sqinter> x .= x"
  by (metis le_refl meet_closed meet_le meet_right top_closed top_lower weak_le_antisym)

end

sublocale weak_complete_lattice \<subseteq> weak_bounded_lattice
  apply (unfold_locales)
  apply (metis Upper_empty empty_subsetI sup_exists)
  apply (metis Lower_empty empty_subsetI inf_exists)
done

locale bounded_lattice = lattice + weak_partial_order_bottom + weak_partial_order_top

context weak_complete_lattice
begin

lemma inf_glb: 
  assumes "A \<subseteq> carrier L"
  shows "greatest L (\<Sqinter>A) (Lower L A)"
proof -
  obtain i where "greatest L i (Lower L A)"
    by (metis assms inf_exists)

  thus ?thesis
    apply (simp add:inf_def)
    apply (rule someI2[of _ "i"])
    apply (auto)
  done
qed

lemma inf_lower:
  assumes "A \<subseteq> carrier L" "x \<in> A"
  shows "\<Sqinter>A \<sqsubseteq> x"
  by (metis assms greatest_Lower_below inf_glb)

lemma inf_greatest: 
  assumes "A \<subseteq> carrier L" "z \<in> carrier L" 
          "(\<And>x. x \<in> A \<Longrightarrow> z \<sqsubseteq> x)"
  shows "z \<sqsubseteq> \<Sqinter>A"
  by (metis Lower_memI assms greatest_le inf_glb)

lemma sup_lub: 
  assumes "A \<subseteq> carrier L"
  shows "least L (\<Squnion>A) (Upper L A)"
proof -
  obtain i where "least L i (Upper L A)"
    by (metis assms sup_exists)

  thus ?thesis
    apply (simp add:sup_def)
    apply (rule someI2[of _ "i"])
    apply (auto)
  done
qed

lemma sup_upper: 
  assumes "A \<subseteq> carrier L" "x \<in> A"
  shows "x \<sqsubseteq> \<Squnion>A"
  by (metis assms least_Upper_above supI)

lemma sup_least:
  assumes "A \<subseteq> carrier L" "z \<in> carrier L" 
          "(\<And>x. x \<in> A \<Longrightarrow> x \<sqsubseteq> z)" 
  shows "\<Squnion>A \<sqsubseteq> z"
  by (metis Upper_memI assms least_le sup_lub)

definition
  LFP :: "('a \<Rightarrow> 'a) \<Rightarrow> 'a" where
  "LFP f = \<Sqinter> {u \<in> carrier L. f u \<sqsubseteq> u}"    --{*least fixed point*}

definition
  GFP:: "('a \<Rightarrow> 'a) \<Rightarrow> 'a" where
  "GFP f = \<Squnion> {u \<in> carrier L. u \<sqsubseteq> f u}"    --{*greatest fixed point*}

lemma LFP_closed:
  "LFP f \<in> carrier L"
  by (metis (lifting) LFP_def inf_closed mem_Collect_eq subsetI)

lemma LFP_lowerbound: 
  assumes "x \<in> carrier L" "f x \<sqsubseteq> x" 
  shows "LFP f \<sqsubseteq> x"
  by (auto intro:inf_lower assms simp add:LFP_def)

lemma LFP_greatest: 
  assumes "x \<in> carrier L" 
          "(\<And>u. \<lbrakk> u \<in> carrier L; f u \<sqsubseteq> u \<rbrakk> \<Longrightarrow> x \<sqsubseteq> u)"
  shows "x \<sqsubseteq> LFP f"
  by (auto simp add:LFP_def intro:inf_greatest assms)

lemma LFP_lemma2: 
  assumes "Mono f" "\<And> x. x \<in> carrier L \<Longrightarrow> f x \<in> carrier L"
  shows "f (LFP f) \<sqsubseteq> LFP f"
  apply (rule LFP_greatest)
  apply (metis LFP_closed assms)
  apply (metis LFP_closed LFP_lowerbound Mono_def assms le_trans)
done

end


text {* Unfortunately we have to hide the algebra lattice syntax so it doesn't conflict
        with the builtin HOL version. *}

no_notation
  le (infixl "\<sqsubseteq>\<index>" 50) and
  lless (infixl "\<sqsubset>\<index>" 50) and
  sup ("\<Squnion>\<index>_" [90] 90) and
  inf ("\<Sqinter>\<index>_" [90] 90) and
  join (infixl "\<squnion>\<index>" 65) and
  meet (infixl "\<sqinter>\<index>" 70) and
  top ("\<top>\<index>") and
  bottom ("\<bottom>\<index>")

end