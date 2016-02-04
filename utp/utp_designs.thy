section {* Designs *}

theory utp_designs
imports
  utp_rel
  utp_wp
  utp_theory
begin

text {* In UTP, in order to explicitly record the termination of a program, 
a subset of alphabetized relations is introduced. These relations are called 
designs and their alphabet should contain the special boolean observational variable ok. 
It is used to record the start and termination of a program. *}

subsection {* Definitions *}

text {* In the following, the definitions of designs alphabets, designs and 
healthiness (well-formedness) conditions are given. The healthiness conditions of
designs are defined by $H1$, $H2$, $H3$ and $H4$.*}

record alpha_d = des_ok::bool

text {* The ok variable is defined using the syntactic translation \emph{VAR} *}

definition "ok = VAR des_ok"

declare ok_def [upred_defs]

lemma uvar_ok [simp]: "uvar ok"
  by (unfold_locales, simp_all add: ok_def)

type_synonym '\<alpha> alphabet_d  = "'\<alpha> alpha_d_scheme alphabet"
type_synonym ('a, '\<alpha>) uvar_d = "('a, '\<alpha> alphabet_d) uvar"
type_synonym ('\<alpha>, '\<beta>) relation_d = "('\<alpha> alphabet_d, '\<beta> alphabet_d) relation"
type_synonym '\<alpha> hrelation_d = "'\<alpha> alphabet_d hrelation"

text {* It would be nice to be able to prove some general distributivity properties
        about these lifting operators. I don't know if that's possible somehow... *}

lift_definition lift_desr :: "('\<alpha>, '\<beta>) relation \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" ("\<lceil>_\<rceil>\<^sub>D") is
"\<lambda> P (A, A'). P (more A, more A')" .

lift_definition drop_desr :: "('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation" ("\<lfloor>_\<rfloor>\<^sub>D") is
"\<lambda> P (A, A'). P (\<lparr> des_ok = True, \<dots> = A \<rparr>, \<lparr> des_ok = True, \<dots> = A' \<rparr>)" .

definition design::"('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" (infixl "\<turnstile>" 60)
where "P \<turnstile> Q = ($ok \<and> P \<Rightarrow> $ok\<acute> \<and> Q)"

text {* An rdesign is a design that uses the Isabelle type system to prevent reference to ok in the
        assumption and commitment. *}

definition rdesign::"('\<alpha>, '\<beta>) relation \<Rightarrow> ('\<alpha>, '\<beta>) relation \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" (infixl "\<turnstile>\<^sub>r" 60)
where "(P \<turnstile>\<^sub>r Q) = \<lceil>P\<rceil>\<^sub>D \<turnstile> \<lceil>Q\<rceil>\<^sub>D" 

text {* An ndesign is a normal design, i.e. where the assumption is a condition *}

definition ndesign::"'\<alpha> condition \<Rightarrow> ('\<alpha>, '\<beta>) relation \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" (infixl "\<turnstile>\<^sub>n" 60)
where "(p \<turnstile>\<^sub>n Q) = (\<lceil>p\<rceil>\<^sub>< \<turnstile>\<^sub>r Q)"

definition skip_d :: "'\<alpha> hrelation_d" ("II\<^sub>D")
where "II\<^sub>D \<equiv> (true \<turnstile>\<^sub>r II)"

definition assigns_d :: "'\<alpha> usubst \<Rightarrow> '\<alpha> hrelation_d" 
where "assigns_d \<sigma> = (true \<turnstile>\<^sub>r assigns_r \<sigma>)"

text {* At some point assignment should be generalised to multiple variables and maybe also
        for selectors. *}

abbreviation assign_d :: "('a, '\<alpha>) uvar \<Rightarrow> ('a, '\<alpha>) uexpr \<Rightarrow> '\<alpha> hrelation_d" (infix ":=\<^sub>D" 40)
where "assign_d x v \<equiv> assigns_d [x \<mapsto>\<^sub>s v]"

definition J :: "'\<alpha> hrelation_d"
where "J = (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)"

definition "H1 (P)  \<equiv>  $ok \<Rightarrow> P"

definition "H2 (P)  \<equiv>  P ;; J"

definition "H3 (P)  \<equiv>  P ;; II\<^sub>D"

definition "H4 (P)  \<equiv> ((P;;true) \<Rightarrow> P)"

abbreviation \<sigma>f::"('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" ("_\<^sup>f" [1000] 1000)
where "\<sigma>f D \<equiv> D\<lbrakk>false/$ok\<acute>\<rbrakk>"

abbreviation \<sigma>t::"('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation_d" ("_\<^sup>t" [1000] 1000)
where "\<sigma>t D \<equiv> D\<lbrakk>true/$ok\<acute>\<rbrakk>"

definition pre_design :: "('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation" ("pre\<^sub>D'(_')") where
"pre\<^sub>D(P) = \<lfloor>\<not> P\<^sup>f\<rfloor>\<^sub>D"

definition post_design :: "('\<alpha>, '\<beta>) relation_d \<Rightarrow> ('\<alpha>, '\<beta>) relation" ("post\<^sub>D'(_')") where
"post\<^sub>D(P) = \<lfloor>P\<^sup>t\<rfloor>\<^sub>D"

definition wp_design :: "('\<alpha>, '\<beta>) relation_d \<Rightarrow> '\<beta> condition \<Rightarrow> '\<alpha> condition" (infix "wp\<^sub>D" 60) where
"Q wp\<^sub>D r = (\<lfloor>pre\<^sub>D(Q) ;; true\<rfloor>\<^sub>< \<and> (post\<^sub>D(Q) wp r))"

declare design_def [upred_defs]
declare rdesign_def [upred_defs]
declare skip_d_def [upred_defs]
declare J_def [upred_defs]
declare pre_design_def [upred_defs]
declare post_design_def [upred_defs]
declare wp_design_def [upred_defs]

declare H1_def [upred_defs]
declare H2_def [upred_defs]
declare H3_def [upred_defs]
declare H4_def [upred_defs]

lemma drop_desr_inv [simp]: "\<lfloor>\<lceil>P\<rceil>\<^sub>D\<rfloor>\<^sub>D = P"
  by (transfer, simp)

lemma lift_desr_inv:
  "\<lbrakk> $ok \<sharp> P; $ok\<acute> \<sharp> P \<rbrakk> \<Longrightarrow> \<lceil>\<lfloor>P\<rfloor>\<^sub>D\<rceil>\<^sub>D = P"
  apply (rel_tac)
  apply (rename_tac P a b)
  apply (drule_tac x="a" in spec)
  apply (drule_tac x="b" in spec)
  apply (drule_tac x="\<lambda> _. True" in spec)
  apply (metis alpha_d.surjective alpha_d.update_convs(1))
  apply (drule_tac x="a" in spec)
  apply (drule_tac x="b" in spec)
  apply (drule_tac x="\<lambda> _. True" in spec)
  apply (metis alpha_d.surjective alpha_d.update_convs(1))
done

subsection {* Design laws *}

lemma lift_desr_unrest_ok [unrest]:
  "$ok \<sharp> \<lceil>P\<rceil>\<^sub>D" "$ok\<acute> \<sharp> \<lceil>P\<rceil>\<^sub>D"
  by (transfer, simp add: ok_def)+

lemma unrest_out_des_lift [unrest]: "out\<alpha> \<sharp> p \<Longrightarrow> out\<alpha> \<sharp> \<lceil>p\<rceil>\<^sub>D"
  apply (pred_tac)
  apply (auto simp add: out\<alpha>_def)
  apply (rename_tac p b v x)
  apply (drule_tac x="alpha_d.more x" in spec)
  apply (drule_tac x="alpha_d.more b" in spec)
  apply (drule_tac x="\<lambda> _. alpha_d.more (v b)" in spec)
  apply (simp)
  apply (rename_tac p b v x)
  apply (drule_tac x="alpha_d.more x" in spec)
  apply (drule_tac x="alpha_d.more b" in spec)
  apply (drule_tac x="\<lambda> _. alpha_d.more (v b)" in spec)
  apply (simp)
done

lemma lift_dists [simp]:
  "\<lceil>true\<rceil>\<^sub>D = true"
  "\<lceil>\<not> P\<rceil>\<^sub>D = (\<not> \<lceil>P\<rceil>\<^sub>D)"
  "\<lceil>P \<and> Q\<rceil>\<^sub>D = (\<lceil>P\<rceil>\<^sub>D \<and> \<lceil>Q\<rceil>\<^sub>D)" 
  by (pred_tac)+

lemma lift_dist_seq [simp]:
  "\<lceil>P ;; Q\<rceil>\<^sub>D = (\<lceil>P\<rceil>\<^sub>D ;; \<lceil>Q\<rceil>\<^sub>D)"
  by (rel_tac, metis alpha_d.select_convs(2))

lemma design_refine:
  assumes "`P1 \<Rightarrow> P2`" "`P1 \<and> Q2 \<Rightarrow> Q1`"
  shows "P1 \<turnstile> Q1 \<sqsubseteq> P2 \<turnstile> Q2"
  using assms unfolding upred_defs
  by pred_tac

theorem design_ok_false [usubst]: "(P \<turnstile> Q)\<lbrakk>false/$ok\<rbrakk> = true"
  by (simp add: design_def usubst)

theorem design_pre: 
  "$ok\<acute> \<sharp> P \<Longrightarrow> \<not> (P \<turnstile> Q)\<^sup>f = ($ok \<and> P\<^sup>f)"
  by (simp add: design_def, subst_tac)
     (metis (no_types, hide_lams) not_conj_deMorgans true_not_false(2) utp_pred.compl_top_eq 
            utp_pred.sup.idem utp_pred.sup_compl_top var_in_var)

theorem rdesign_pre [simp]: "pre\<^sub>D(P \<turnstile>\<^sub>r Q) = P"
  by pred_tac

theorem design_post [simp]: "post\<^sub>D(P \<turnstile>\<^sub>r Q) = (P \<Rightarrow> Q)"
  by pred_tac

theorem design_true_left_zero: "(true ;; (P \<turnstile> Q)) = true"
proof -
  have "(true ;; (P \<turnstile> Q)) = (\<^bold>\<exists> ok\<^sub>0 \<bullet> true\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<acute>\<rbrakk> ;; (P \<turnstile> Q)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<rbrakk>)"
    by (subst seqr_middle[of ok], simp_all)
  also have "... = ((true\<lbrakk>false/$ok\<acute>\<rbrakk> ;; (P \<turnstile> Q)\<lbrakk>false/$ok\<rbrakk>) \<or> (true\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (P \<turnstile> Q)\<lbrakk>true/$ok\<rbrakk>))"
    by (simp add: disj_comm false_alt_def true_alt_def)
  also have "... = ((true\<lbrakk>false/$ok\<acute>\<rbrakk> ;; true\<^sub>h) \<or> (true ;; ((P \<turnstile> Q)\<lbrakk>true/$ok\<rbrakk>)))"
    by (subst_tac, rel_tac)
  also have "... = true"
    by (subst_tac, simp add: precond_right_unit unrest)
  finally show ?thesis .
qed
  
theorem design_composition:
  assumes 
    "$ok \<sharp> P1" "$ok\<acute> \<sharp> P1" "$ok \<sharp> P2" "$ok\<acute> \<sharp> P2"
    "$ok \<sharp> Q1" "$ok\<acute> \<sharp> Q1" "$ok \<sharp> Q2" "$ok\<acute> \<sharp> Q2"
  shows "((P1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile> (Q1 ;; Q2))"
proof -
  have "((P1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = (\<^bold>\<exists> ok\<^sub>0 \<bullet> ((P1 \<turnstile> Q1)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<acute>\<rbrakk> ;; (P2 \<turnstile> Q2)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<rbrakk>))"
    by (rule seqr_middle, simp)
  also have " ... 
        = (((P1 \<turnstile> Q1)\<lbrakk>false/$ok\<acute>\<rbrakk> ;; (P2 \<turnstile> Q2)\<lbrakk>false/$ok\<rbrakk>) 
            \<or> ((P1 \<turnstile> Q1)\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (P2 \<turnstile> Q2)\<lbrakk>true/$ok\<rbrakk>))"
    by (simp add: true_alt_def false_alt_def, pred_tac)
  also from assms
  have "... = ((($ok \<and> P1 \<Rightarrow> Q1) ;; (P2 \<Rightarrow> $ok\<acute> \<and> Q2)) \<or> ((\<not> ($ok \<and> P1)) ;; true))"
    by (simp add: design_def usubst unrest, pred_tac)
  also have "... = ((\<not>$ok ;; true\<^sub>h) \<or> (\<not>P1 ;; true) \<or> (Q1 ;; \<not>P2) \<or> ($ok\<acute> \<and> (Q1 ;; Q2)))"
    by (rel_tac)
  also have "... = (\<not> (\<not> P1 ;; true) \<and> \<not> (Q1 ;; \<not> P2)) \<turnstile> (Q1 ;; Q2)"
    by (simp add: precond_right_unit design_def unrest, rel_tac)
  finally show ?thesis .
qed

theorem rdesign_composition:
  "((P1 \<turnstile>\<^sub>r Q1) ;; (P2 \<turnstile>\<^sub>r Q2)) = (((\<not> ((\<not> P1) ;; true)) \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile>\<^sub>r (Q1 ;; Q2))"
  by (simp add: rdesign_def design_composition unrest)

lemma skip_d_alt_def: "II\<^sub>D = true \<turnstile> II"
  by (rel_tac)

theorem design_skip_idem [simp]:
  "(II\<^sub>D ;; II\<^sub>D) = II\<^sub>D"
  by (simp add: skip_d_def urel_defs, pred_tac)

theorem design_composition_cond:
  assumes 
    "$ok \<sharp> p1" "out\<alpha> \<sharp> p1" "$ok \<sharp> P2" "$ok\<acute> \<sharp> P2"
    "$ok \<sharp> Q1" "$ok\<acute> \<sharp> Q1" "$ok \<sharp> Q2" "$ok\<acute> \<sharp> Q2"
  shows "((p1 \<turnstile> Q1) ;; (P2 \<turnstile> Q2)) = ((p1 \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile> (Q1 ;; Q2))"
  using assms
  by (simp add: design_composition unrest precond_right_unit)

theorem rdesign_composition_cond:
  assumes "out\<alpha> \<sharp> p1"
  shows "((p1 \<turnstile>\<^sub>r Q1) ;; (P2 \<turnstile>\<^sub>r Q2)) = ((p1 \<and> \<not> (Q1 ;; (\<not> P2))) \<turnstile>\<^sub>r (Q1 ;; Q2))"
  using assms
  by (simp add: rdesign_def design_composition_cond unrest)
  

theorem design_composition_wp:
  fixes Q1 Q2 :: "'a hrelation_d"
  assumes 
    "ok \<sharp> p1" "ok \<sharp> p2"
    "$ok \<sharp> Q1" "$ok\<acute> \<sharp> Q1" "$ok \<sharp> Q2" "$ok\<acute> \<sharp> Q2"
  shows "((\<lceil>p1\<rceil>\<^sub>< \<turnstile> Q1) ;; (\<lceil>p2\<rceil>\<^sub>< \<turnstile> Q2)) = ((\<lceil>p1 \<and> Q1 wp p2\<rceil>\<^sub><) \<turnstile> (Q1 ;; Q2))"
  using assms
  by (simp add: design_composition_cond unrest, rel_tac)

theorem rdesign_composition_wp:
  fixes Q1 Q2 :: "'a hrelation"
  shows "((\<lceil>p1\<rceil>\<^sub>< \<turnstile>\<^sub>r Q1) ;; (\<lceil>p2\<rceil>\<^sub>< \<turnstile>\<^sub>r Q2)) = ((\<lceil>p1 \<and> Q1 wp p2\<rceil>\<^sub><) \<turnstile>\<^sub>r (Q1 ;; Q2))"
  by (simp add: rdesign_composition_cond unrest, rel_tac)

theorem rdesign_wp [wp]:
  "(\<lceil>p\<rceil>\<^sub>< \<turnstile>\<^sub>r Q) wp\<^sub>D r = (p \<and> Q wp r)"
  by rel_tac

theorem wpd_seq_r:
  fixes Q1 Q2 :: "'\<alpha> hrelation"
  shows "(\<lceil>p1\<rceil>\<^sub>< \<turnstile>\<^sub>r Q1 ;; \<lceil>p2\<rceil>\<^sub>< \<turnstile>\<^sub>r Q2) wp\<^sub>D r = (\<lceil>p1\<rceil>\<^sub>< \<turnstile>\<^sub>r Q1) wp\<^sub>D ((\<lceil>p2\<rceil>\<^sub>< \<turnstile>\<^sub>r Q2) wp\<^sub>D r)"
  apply (simp add: wp)
  apply (subst rdesign_composition_wp)
  apply (simp only: wp)
  apply (rel_tac)
done

theorem design_left_unit [simp]:
  "(II\<^sub>D ;; P \<turnstile>\<^sub>r Q) = (P \<turnstile>\<^sub>r Q)"
  by (simp add: skip_d_def urel_defs, pred_tac)

theorem design_right_cond_unit [simp]:
  assumes "out\<alpha> \<sharp> p"
  shows "(p \<turnstile>\<^sub>r Q ;; II\<^sub>D) = (p \<turnstile>\<^sub>r Q)"
  using assms
  by (simp add: skip_d_def rdesign_composition_cond)

lemma lift_des_skip_dr_unit [simp]:
  "(\<lceil>P\<rceil>\<^sub>D ;; \<lceil>II\<rceil>\<^sub>D) = \<lceil>P\<rceil>\<^sub>D"
  "(\<lceil>II\<rceil>\<^sub>D ;; \<lceil>P\<rceil>\<^sub>D) = \<lceil>P\<rceil>\<^sub>D"
  by rel_tac rel_tac

subsection {* H1: No observation is allowed before initiation *}

lemma H1_idem:
  "H1 (H1 P) = H1(P)"
  by pred_tac

lemma H1_monotone:
  "P \<sqsubseteq> Q \<Longrightarrow> H1(P) \<sqsubseteq> H1(Q)"
  by pred_tac

lemma H1_design_skip:
  "H1(II) = II\<^sub>D"
  by rel_tac

text {* The H1 algebraic laws are valid only when $\alpha(R)$ is homogeneous. This should maybe be
        generalised. *}

theorem H1_algebraic_intro:
  assumes 
    "(true\<^sub>h ;; R) = true\<^sub>h" 
    "(II\<^sub>D ;; R) = R"
  shows "R is H1"
proof -
  have "R = (II\<^sub>D ;; R)" by (simp add: assms(2))
  also have "... = (H1(II) ;; R)"
    by (simp add: H1_design_skip)
  also have "... = (($ok \<Rightarrow> II) ;; R)"
    by (simp add: H1_def)
  also have "... = ((\<not> $ok ;; R) \<or> R)"
    by (simp add: impl_alt_def seqr_or_distl)
  also have "... = (((\<not> $ok ;; true\<^sub>h) ;; R) \<or> R)"
    by (simp add: precond_right_unit unrest)
  also have "... = ((\<not> $ok ;; true\<^sub>h) \<or> R)"
    by (metis assms(1) seqr_assoc)
  also have "... = ($ok \<Rightarrow> R)"
    by (simp add: impl_alt_def precond_right_unit unrest)
  finally show ?thesis by (metis H1_def Healthy_def')
qed

lemma nok_not_false:
  "(\<not> $ok) \<noteq> false"
  by (simp add:ok_def, pred_tac, simp add: in_var_def, metis alpha_d.select_convs(1) fst_conv)

theorem H1_left_zero:
  assumes "P is H1"
  shows "(true\<^sub>h ;; P) = true\<^sub>h"
proof -
  from assms have "(true\<^sub>h ;; P) = (true\<^sub>h ;; ($ok \<Rightarrow> P))"
    by (simp add: H1_def Healthy_def')
  also from assms have "... = (true\<^sub>h ;; (\<not> $ok \<or> P))"
    by (simp add: impl_alt_def)
  also from assms have "... = ((true\<^sub>h ;; \<not> $ok) \<or> (true\<^sub>h ;; P))"
    using seqr_or_distr by blast
  also from assms have "... = (true \<or> (true ;; P))"
    by (simp add: nok_not_false precond_left_zero unrest)
  finally show ?thesis by rel_tac
qed

theorem H1_left_unit:
  fixes P :: "'\<alpha> hrelation_d"
  assumes "P is H1"
  shows "(II\<^sub>D ;; P) = P"
proof -
  have "(II\<^sub>D ;; P) = (($ok \<Rightarrow> II) ;; P)"
    by (metis H1_def H1_design_skip)
  also have "... = ((\<not> $ok ;; P) \<or> P)"
    by (simp add: impl_alt_def seqr_or_distl)
  also from assms have "... = (((\<not> $ok ;; true\<^sub>h) ;; P) \<or> P)"
    by (simp add: precond_right_unit unrest)
  also have "... = ((\<not> $ok ;; (true\<^sub>h ;; P)) \<or> P)"
    by (simp add: seqr_assoc)
  also from assms have "... = ($ok \<Rightarrow> P)"
    by (simp add: H1_left_zero impl_alt_def precond_right_unit unrest)
  finally show ?thesis using assms
    by (simp add: H1_def Healthy_def')
qed

theorem H1_algebraic:
  "P is H1 \<longleftrightarrow> (true\<^sub>h ;; P) = true\<^sub>h \<and> (II\<^sub>D ;; P) = P"
  using H1_algebraic_intro H1_left_unit H1_left_zero by blast

theorem H1_nok_left_zero:
  fixes P :: "'\<alpha> hrelation_d"
  assumes "P is H1"
  shows "(\<not> $ok ;; P) = (\<not> $ok)"  
proof -
  have "(\<not> $ok ;; P) = ((\<not> $ok ;; true\<^sub>h) ;; P)"
    by (simp add: precond_right_unit unrest)
  also have "... = ((\<not> $ok) ;; true\<^sub>h)"
    by (metis H1_left_zero assms seqr_assoc)
  also have "... = (\<not> $ok)"
    by (simp add: precond_right_unit unrest)
  finally show ?thesis .
qed

subsection {* H2: A specification cannot require non-termination *}

lemma J_split: 
  shows "(P ;; J) = (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))"
proof -
  have "(P ;; J) = (P ;; (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D))"
    by (simp add: H2_def J_def design_def)
  also have "... = (P ;; (($ok \<Rightarrow> $ok \<and> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D))"
    by rel_tac
  also have "... = ((P ;; (\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D)) \<or> (P ;; ($ok \<and> (\<lceil>II\<rceil>\<^sub>D \<and> $ok\<acute>))))"
    by rel_tac
  also have "... = (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))"
  proof -
    have "(P ;; (\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D)) = P\<^sup>f"
    proof -
      have "(P ;; (\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D)) = ((P \<and> \<not> $ok\<acute>) ;; \<lceil>II\<rceil>\<^sub>D)"
        by rel_tac
      also have "... = (\<exists> $ok\<acute> \<bullet> P \<and> $ok\<acute> =\<^sub>u false)"
        by (rel_tac, metis (mono_tags, lifting) alpha_d.surjective alpha_d.update_convs(1))
      also have "... = P\<^sup>f"
        by (metis one_point out_var_uvar ouvar_def unrest_false uvar_ok)
     finally show ?thesis .
    qed
    moreover have "(P ;; ($ok \<and> (\<lceil>II\<rceil>\<^sub>D \<and> $ok\<acute>))) = (P\<^sup>t \<and> $ok\<acute>)"
    proof -
      have "(P ;; ($ok \<and> (\<lceil>II\<rceil>\<^sub>D \<and> $ok\<acute>))) = (P ;; ($ok \<and> II))"
        by (rel_tac, metis alpha_d.equality)
      also have "... = (P\<^sup>t \<and> $ok\<acute>)"
        by (rel_tac, metis (full_types) alpha_d.surjective alpha_d.update_convs(1))+
      finally show ?thesis .
    qed
    ultimately show ?thesis
      by simp
  qed 
  finally show ?thesis .
qed

lemma H2_split: 
  shows "H2(P) = (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))"
  by (simp add: H2_def J_split)
 
theorem H2_equivalence:
  "P is H2 \<longleftrightarrow> `P\<^sup>f \<Rightarrow> P\<^sup>t`"
proof -
  have "`P \<Leftrightarrow> (P ;; J)` \<longleftrightarrow> `P \<Leftrightarrow> (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>))`"
    by (simp add: J_split)
  also from assms have "... \<longleftrightarrow> `(P \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t \<and> $ok\<acute>)\<^sup>f \<and> (P \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t \<and> $ok\<acute>)\<^sup>t`"
    by (simp add: subst_bool_split)
  also from assms have "... = `(P\<^sup>f \<Leftrightarrow> P\<^sup>f) \<and> (P\<^sup>t \<Leftrightarrow> P\<^sup>f \<or> P\<^sup>t)`"
    by subst_tac
  also have "... = `P\<^sup>t \<Leftrightarrow> (P\<^sup>f \<or> P\<^sup>t)`"
    by pred_tac
  also have "... = `(P\<^sup>f \<Rightarrow> P\<^sup>t)`"
    by pred_tac
  finally show ?thesis using assms
    by (metis H2_def Healthy_def' taut_iff_eq)
qed

lemma H2_equiv:
  "P is H2 \<longleftrightarrow> P\<^sup>t \<sqsubseteq> P\<^sup>f" 
  using H2_equivalence refBy_order by blast

lemma H2_design:
  assumes "$ok \<sharp> P" "$ok\<acute> \<sharp> P" "$ok \<sharp> Q" "$ok\<acute> \<sharp> Q"
  shows "H2(P \<turnstile> Q) = P \<turnstile> Q"
  using assms
  by (simp add: H2_split design_def usubst unrest, pred_tac)

lemma H2_rdesign:
  "H2(P \<turnstile>\<^sub>r Q) = P \<turnstile>\<^sub>r Q"
  by (simp add: H2_design unrest rdesign_def)

theorem J_idem:
  "(J ;; J) = J"
  by (simp add: J_def urel_defs, pred_tac)

theorem H2_idem:
  "H2(H2(P)) = H2(P)"
  by (metis H2_def J_idem seqr_assoc)

theorem H2_not_okay: "H2 (\<not> $ok) = (\<not> $ok)"
proof -
  have "H2 (\<not> $ok) = ((\<not> $ok)\<^sup>f \<or> ((\<not> $ok)\<^sup>t \<and> $ok\<acute>))"
    by (simp add: H2_split)
  also have "... = (\<not> $ok \<or> (\<not> $ok) \<and> $ok\<acute>)"
    by (subst_tac, simp add: iuvar_def)
  also have "... = (\<not> $ok)"
    by pred_tac
  finally show ?thesis .
qed

theorem H1_H2_commute: 
  "H1 (H2 P) = H2 (H1 P)"
proof -
  have "H2 (H1 P) = (($ok \<Rightarrow> P) ;; J)"
    by (simp add: H1_def H2_def)
  also from assms have "... = ((\<not> $ok \<or> P) ;; J)"
    by rel_tac
  also have "... = ((\<not> $ok ;; J) \<or> (P ;; J))"
    using seqr_or_distl by blast
  also have "... =  ((H2 (\<not> $ok)) \<or> H2(P))"
    by (simp add: H2_def)
  also have "... =  ((\<not> $ok) \<or> H2(P))"
    by (simp add: H2_not_okay)
  also have "... = H1(H2(P))"
    by rel_tac
  finally show ?thesis by simp
qed

lemma ok_pre: "($ok \<and> \<lceil>pre\<^sub>D(P)\<rceil>\<^sub>D) = ($ok \<and> (\<not> P\<^sup>f))"
  by (pred_tac, metis (full_types) alpha_d.surjective alpha_d.update_convs(1))+

lemma ok_post: "($ok \<and> \<lceil>post\<^sub>D(P)\<rceil>\<^sub>D) = ($ok \<and> (P\<^sup>t))"
  by (pred_tac, metis (full_types) alpha_d.surjective alpha_d.update_convs(1))+

theorem H1_H2_is_rdesign:
  assumes "P is H1" "P is H2"
  shows "P = pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P)"
proof -
  from assms have "P = ($ok \<Rightarrow> H2(P))"
    by (simp add: H1_def Healthy_def')
  also have "... = ($ok \<Rightarrow> (P\<^sup>f \<or> (P\<^sup>t \<and> $ok\<acute>)))"
    by (metis H2_split)
  also have "... = ($ok \<and> (\<not> P\<^sup>f) \<Rightarrow> $ok\<acute> \<and> P\<^sup>t)"
    by pred_tac
  also have "... = ($ok \<and> (\<not> P\<^sup>f) \<Rightarrow> $ok\<acute> \<and> $ok \<and> P\<^sup>t)"
    by pred_tac
  also have "... = ($ok \<and> \<lceil>pre\<^sub>D(P)\<rceil>\<^sub>D \<Rightarrow> $ok\<acute> \<and> $ok \<and> \<lceil>post\<^sub>D(P)\<rceil>\<^sub>D)"
    by (simp add: ok_post ok_pre)
  also have "... = ($ok \<and> \<lceil>pre\<^sub>D(P)\<rceil>\<^sub>D \<Rightarrow> $ok\<acute> \<and> \<lceil>post\<^sub>D(P)\<rceil>\<^sub>D)"
    by pred_tac
  also from assms have "... =  pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P)"
    by (simp add: rdesign_def design_def)
  finally show ?thesis .
qed

abbreviation "H1_H2 P \<equiv> H1 (H2 P)"

subsection {* H3: The design assumption is a precondition *}

theorem H3_idem:
  "H3(H3(P)) = H3(P)"
  by (metis H3_def design_skip_idem seqr_assoc)

theorem rdesign_H3_iff_pre: 
  "P \<turnstile>\<^sub>r Q is H3 \<longleftrightarrow> P = (P ;; true)"
proof -
  have "(P \<turnstile>\<^sub>r Q ;; II\<^sub>D) = (P \<turnstile>\<^sub>r Q ;; true \<turnstile>\<^sub>r II)"
    by (simp add: skip_d_def)
  also from assms have "... = (\<not> (\<not> P ;; true) \<and> \<not> (Q ;; \<not> true)) \<turnstile>\<^sub>r (Q ;; II)"
    by (simp add: rdesign_composition)
  also from assms have "... = (\<not> (\<not> P ;; true) \<and> \<not> (Q ;; \<not> true)) \<turnstile>\<^sub>r Q"
    by simp
  also have "... = (\<not> (\<not> P ;; true)) \<turnstile>\<^sub>r Q"
    by pred_tac
  finally have "P \<turnstile>\<^sub>r Q is H3 \<longleftrightarrow> P \<turnstile>\<^sub>r Q = (\<not> (\<not> P ;; true)) \<turnstile>\<^sub>r Q"
    by (metis H3_def Healthy_def')
  also have "... \<longleftrightarrow> P = (\<not> (\<not> P ;; true))"
    by (metis rdesign_pre)
  also have "... \<longleftrightarrow> P = (P ;; true)"
    by (simp add: seqr_true_lemma)
  finally show ?thesis .
qed

theorem design_H3_iff_pre: 
  assumes "$ok \<sharp> P" "$ok\<acute> \<sharp> P" "$ok \<sharp> Q" "$ok\<acute> \<sharp> Q"
  shows "P \<turnstile> Q is H3 \<longleftrightarrow> P = (P ;; true)"
proof -
  have "P \<turnstile> Q = \<lfloor>P\<rfloor>\<^sub>D \<turnstile>\<^sub>r \<lfloor>Q\<rfloor>\<^sub>D"
    by (simp add: assms lift_desr_inv rdesign_def)
  moreover hence "\<lfloor>P\<rfloor>\<^sub>D \<turnstile>\<^sub>r \<lfloor>Q\<rfloor>\<^sub>D is H3 \<longleftrightarrow> \<lfloor>P\<rfloor>\<^sub>D = (\<lfloor>P\<rfloor>\<^sub>D ;; true)"
    using rdesign_H3_iff_pre by blast
  ultimately show ?thesis
    by (metis assms drop_desr_inv lift_desr_inv lift_dist_seq lift_dists(1))
qed

theorem H1_H3_commute:
  "H1 (H3 P) = H3 (H1 P)"
  by rel_tac

lemma skip_d_absorb_J_1:
  "(II\<^sub>D ;; J) = II\<^sub>D"
  by (metis H2_def H2_rdesign skip_d_def)

lemma skip_d_absorb_J_2:
  "(J ;; II\<^sub>D) = II\<^sub>D"
proof -
  have "(J ;; II\<^sub>D) = (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D ;; true \<turnstile> II)"
    by (simp add: J_def skip_d_alt_def)
  also have "... = (\<^bold>\<exists> ok\<^sub>0 \<bullet> (($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<acute>\<rbrakk> ;; (true \<turnstile> II)\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<rbrakk>)"
    by (subst seqr_middle[of ok], simp_all)
  also have "... = (((($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>false/$ok\<acute>\<rbrakk> ;; (true \<turnstile> II)\<lbrakk>false/$ok\<rbrakk>)
                  \<or> ((($ok \<Rightarrow> $ok\<acute>) \<and> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>true/$ok\<acute>\<rbrakk> ;; (true \<turnstile> II)\<lbrakk>true/$ok\<rbrakk>))"
    by (simp add: disj_comm false_alt_def true_alt_def)
  also have "... = ((\<not> $ok \<and> \<lceil>II\<rceil>\<^sub>D ;; true) \<or> (\<lceil>II\<rceil>\<^sub>D ;; $ok\<acute> \<and> \<lceil>II\<rceil>\<^sub>D))"
    by (simp add: usubst unrest design_def iuvar_def ouvar_def, rel_tac)
  also have "... = II\<^sub>D"
    by rel_tac
  finally show ?thesis .
qed

lemma H2_H3_absorb:
  "H2 (H3 P) = H3 P"
  by (metis H2_def H3_def seqr_assoc skip_d_absorb_J_1)

lemma H3_H2_absorb:
  "H3 (H2 P) = H3 P"
  by (metis H2_def H3_def seqr_assoc skip_d_absorb_J_2)

theorem H2_H3_commute:
  "H2 (H3 P) = H3 (H2 P)"
  by (simp add: H2_H3_absorb H3_H2_absorb)

theorem H3_design_pre:
  assumes "$ok \<sharp> p" "out\<alpha> \<sharp> p" "$ok \<sharp> Q" "$ok\<acute> \<sharp> Q"
  shows "H3(p \<turnstile> Q) = p \<turnstile> Q"
  using assms
  by (metis Healthy_def' design_H3_iff_pre precond_right_unit unrest_out\<alpha>_var uvar_ok) 

theorem H3_rdesign_pre:
  assumes "out\<alpha> \<sharp> p"
  shows "H3(p \<turnstile>\<^sub>r Q) = p \<turnstile>\<^sub>r Q"
  using assms
  by (simp add: H3_def)

theorem H1_H3_is_rdesign:
  assumes "P is H1" "P is H3"
  shows "P = pre\<^sub>D(P) \<turnstile>\<^sub>r post\<^sub>D(P)"
  by (metis H1_H2_is_rdesign H2_H3_absorb Healthy_def' assms)

theorem H1_H3_is_normal_design:
  assumes "P is H1" "P is H3"
  shows "P = \<lfloor>pre\<^sub>D(P)\<rfloor>\<^sub>< \<turnstile>\<^sub>n post\<^sub>D(P)"
  by (metis H1_H3_is_rdesign assms drop_pre_inv ndesign_def precond_equiv rdesign_H3_iff_pre)

abbreviation "H1_H3 p \<equiv> H1 (H3 p)"

theorem wpd_seq_r_H1_H2 [wp]:
  fixes P Q :: "'\<alpha> hrelation_d"
  assumes "P is H1_H3" "Q is H1_H3"
  shows "(P ;; Q) wp\<^sub>D r = P wp\<^sub>D (Q wp\<^sub>D r)"
  by (smt H1_H3_commute H1_H3_is_rdesign H1_idem Healthy_def' assms(1) assms(2) drop_pre_inv precond_equiv rdesign_H3_iff_pre wpd_seq_r)

subsection {* H4: Feasibility *}

theorem H4_idem:
  "H4(H4(P)) = H4(P)"
  by pred_tac

end