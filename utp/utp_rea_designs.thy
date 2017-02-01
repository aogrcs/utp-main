section {* Reactive designs *}

theory utp_rea_designs
  imports utp_reactive
begin

subsection {* Commutativity properties *}

lemma H2_R1_comm: "H2(R1(P)) = R1(H2(P))"
  by (rel_auto)

lemma H2_R2s_comm: "H2(R2s(P)) = R2s(H2(P))"
  by (rel_auto)  

lemma H2_R2_comm: "H2(R2(P)) = R2(H2(P))"
  by (simp add: H2_R1_comm H2_R2s_comm R2_def)

lemma H2_R3_comm: "H2(R3c(P)) = R3c(H2(P))"
  by (simp add: R3c_H2_commute)

lemma H2_R3h_comm: "H2(R3h(P)) = R3h(H2(P))"
  by (rel_auto)

lemma R3c_via_H1: "R1(R3c(H1(P))) = R1(H1(R3(P)))"
  by rel_auto

lemma skip_rea_via_H1: "II\<^sub>r = R1(H1(R3(II)))"
  by rel_auto

lemma R1_true_left_zero_R: "(R1(true) ;; \<^bold>R(P)) = R1(true)"
  by (rel_auto)

lemma skip_rea_R1_lemma: "II\<^sub>r = R1($ok \<Rightarrow> II)"
  by (rel_auto)

lemma skip_rea_R1_dskip: "II\<^sub>r = R1(II\<^sub>D)"
  by (rel_auto)

subsection {* Reactive design composition *}

text {* Pedro's proof for R1 design composition *}

lemma R1_design_composition:
  fixes P Q :: "('t::ordered_cancel_monoid_diff,'\<alpha>,'\<beta>) relation_rp"
  and R S :: "('t,'\<beta>,'\<gamma>) relation_rp"
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q" "$ok \<sharp> R" "$ok \<sharp> S"
  shows
  "(R1(P \<turnstile> Q) ;; R1(R \<turnstile> S)) = 
   R1((\<not> (R1(\<not> P) ;; R1(true)) \<and> \<not> (R1(Q) ;; R1(\<not> R))) \<turnstile> (R1(Q) ;; R1(S)))"
proof -
  have "(R1(P \<turnstile> Q) ;; R1(R \<turnstile> S)) = (\<^bold>\<exists> ok\<^sub>0 \<bullet> (R1(P \<turnstile> Q))\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<acute>\<rbrakk> ;; (R1(R \<turnstile> S))\<lbrakk>\<guillemotleft>ok\<^sub>0\<guillemotright>/$ok\<rbrakk>)"
    using seqr_middle vwb_lens_ok by blast
  also from assms have "... = (\<^bold>\<exists> ok\<^sub>0 \<bullet> R1(($ok \<and> P) \<Rightarrow> (\<guillemotleft>ok\<^sub>0\<guillemotright> \<and> Q)) ;; R1((\<guillemotleft>ok\<^sub>0\<guillemotright>  \<and> R) \<Rightarrow> ($ok\<acute> \<and> S)))"
    by (simp add: design_def R1_def usubst unrest)
  also from assms have "... = ((R1(($ok \<and> P) \<Rightarrow> (true \<and> Q)) ;; R1((true \<and> R) \<Rightarrow> ($ok\<acute> \<and> S)))
                             \<or> (R1(($ok \<and> P) \<Rightarrow> (false \<and> Q)) ;; R1((false \<and> R) \<Rightarrow> ($ok\<acute> \<and> S))))"
    by (simp add: false_alt_def true_alt_def)
  also from assms have "... = ((R1(($ok \<and> P) \<Rightarrow> Q) ;; R1(R \<Rightarrow> ($ok\<acute> \<and> S))) 
                             \<or> (R1(\<not> ($ok \<and> P)) ;; R1(true)))"
    by simp
  also from assms have "... = ((R1(\<not> $ok \<or> \<not> P \<or> Q) ;; R1(\<not> R \<or> ($ok\<acute> \<and> S))) 
                             \<or> (R1(\<not> $ok \<or> \<not> P) ;; R1(true)))"
    by (simp add: impl_alt_def utp_pred.sup.assoc)
  also from assms have "... = (((R1(\<not> $ok \<or> \<not> P) \<or> R1(Q)) ;; R1(\<not> R \<or> ($ok\<acute> \<and> S))) 
                               \<or> (R1(\<not> $ok \<or> \<not> P) ;; R1(true)))"
    by (simp add: R1_disj utp_pred.disj_assoc)
  also from assms have "... = ((R1(\<not> $ok \<or> \<not> P) ;; R1(\<not> R \<or> ($ok\<acute> \<and> S)))
                               \<or> (R1(Q) ;; R1(\<not> R \<or> ($ok\<acute> \<and> S))) 
                               \<or> (R1(\<not> $ok \<or> \<not> P) ;; R1(true)))"
    by (simp add: seqr_or_distl utp_pred.sup.assoc)
  also from assms have "... = ((R1(Q) ;; R1(\<not> R \<or> ($ok\<acute> \<and> S))) 
                               \<or> (R1(\<not> $ok \<or> \<not> P) ;; R1(true)))"
    by rel_blast
  also from assms have "... = ((R1(Q) ;; (R1(\<not> R) \<or> R1(S) \<and> $ok\<acute>)) 
                               \<or> (R1(\<not> $ok \<or> \<not> P) ;; R1(true)))"
    by (simp add: R1_disj R1_extend_conj utp_pred.inf_commute)
  also have "... = ((R1(Q) ;; (R1(\<not> R) \<or> R1(S) \<and> $ok\<acute>)) 
                  \<or> ((R1(\<not> $ok) :: ('t,'\<alpha>,'\<beta>) relation_rp) ;; R1(true)) 
                  \<or> (R1(\<not> P) ;; R1(true)))"
    by (simp add: R1_disj seqr_or_distl)
  also have "... = ((R1(Q) ;; (R1(\<not> R) \<or> R1(S) \<and> $ok\<acute>)) 
                  \<or> (R1(\<not> $ok))
                  \<or> (R1(\<not> P) ;; R1(true)))"
  proof -
    have "((R1(\<not> $ok) :: ('t,'\<alpha>,'\<beta>) relation_rp) ;; R1(true)) = 
           (R1(\<not> $ok) :: ('t,'\<alpha>,'\<gamma>) relation_rp)"
      by (rel_auto)
    thus ?thesis
      by simp
  qed
  also have "... = ((R1(Q) ;; (R1(\<not> R) \<or> (R1(S \<and> $ok\<acute>)))) 
                  \<or> R1(\<not> $ok)
                  \<or> (R1(\<not> P) ;; R1(true)))"
    by (simp add: R1_extend_conj)
  also have "... = ( (R1(Q) ;; (R1 (\<not> R)))
                   \<or> (R1(Q) ;; (R1(S \<and> $ok\<acute>)))
                   \<or> R1(\<not> $ok)
                   \<or> (R1(\<not> P) ;; R1(true)))"
    by (simp add: seqr_or_distr utp_pred.sup.assoc)
  also have "... = R1( (R1(Q) ;; (R1 (\<not> R)))
                     \<or> (R1(Q) ;; (R1(S \<and> $ok\<acute>)))
                     \<or> (\<not> $ok)
                     \<or> (R1(\<not> P) ;; R1(true)))"
    by (simp add: R1_disj R1_seqr)
  also have "... = R1( (R1(Q) ;; (R1 (\<not> R)))
                     \<or> ((R1(Q) ;; R1(S)) \<and> $ok\<acute>)
                     \<or> (\<not> $ok)
                     \<or> (R1(\<not> P) ;; R1(true)))"
    by (rel_blast)
  also have "... = R1(\<not>($ok \<and> \<not> (R1(\<not> P) ;; R1(true)) \<and> \<not> (R1(Q) ;; (R1 (\<not> R))))
                     \<or>  ((R1(Q) ;; R1(S)) \<and> $ok\<acute>))"
    by (rel_blast)
  also have "... = R1(($ok \<and> \<not> (R1(\<not> P) ;; R1(true)) \<and> \<not> (R1(Q) ;; (R1 (\<not> R))))
                      \<Rightarrow> ($ok\<acute> \<and> (R1(Q) ;; R1(S))))"
    by (simp add: impl_alt_def utp_pred.inf_commute)
  also have "... = R1((\<not> (R1(\<not> P) ;; R1(true)) \<and> \<not> (R1(Q) ;; R1(\<not> R))) \<turnstile> (R1(Q) ;; R1(S)))"
    by (simp add: design_def)
  finally show ?thesis .
qed

definition [upred_defs]: "R3c_pre(P) = (true \<triangleleft> $wait \<triangleright> P)"

definition [upred_defs]: "R3c_post(P) = (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> P)"

definition [upred_defs]: "R3h_post(P) = ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> P)"

lemma R3c_pre_conj: "R3c_pre(P \<and> Q) = (R3c_pre(P) \<and> R3c_pre(Q))"
  by rel_auto

lemma R3c_pre_seq:
  "(true ;; Q) = true \<Longrightarrow> R3c_pre(P ;; Q) = (R3c_pre(P) ;; Q)"
  by (rel_auto)

lemma R2s_design: "R2s(P \<turnstile> Q) = (R2s(P) \<turnstile> R2s(Q))"
  by (simp add: R2s_def design_def usubst)

lemma R2c_design: "R2c(P \<turnstile> Q) = (R2c(P) \<turnstile> R2c(Q))"
  by (simp add: design_def impl_alt_def R2c_disj R2c_not R2c_ok R2c_and R2c_ok')

lemma R1_R3c_design:
  "R1(R3c(P \<turnstile> Q)) = R1(R3c_pre(P) \<turnstile> R3c_post(Q))"
  by (rel_auto)

lemma R1_R3h_design:
  "R1(R3h(P \<turnstile> Q)) = R1(R3c_pre(P) \<turnstile> R3h_post(Q))"
  by (rel_auto)

lemma unrest_ok_R2s [unrest]: "$ok \<sharp> P \<Longrightarrow> $ok \<sharp> R2s(P)"
  by (simp add: R2s_def unrest)

lemma unrest_ok'_R2s [unrest]: "$ok\<acute> \<sharp> P \<Longrightarrow> $ok\<acute> \<sharp> R2s(P)"
  by (simp add: R2s_def unrest)

lemma unrest_ok_R2c [unrest]: "$ok \<sharp> P \<Longrightarrow> $ok \<sharp> R2c(P)"
  by (simp add: R2c_def unrest)

lemma unrest_ok'_R2c [unrest]: "$ok\<acute> \<sharp> P \<Longrightarrow> $ok\<acute> \<sharp> R2c(P)"
  by (simp add: R2c_def unrest)

lemma unrest_ok_R3c_pre [unrest]: "$ok \<sharp> P \<Longrightarrow> $ok \<sharp> R3c_pre(P)"
  by (simp add: R3c_pre_def cond_def unrest)

lemma unrest_ok'_R3c_pre [unrest]: "$ok\<acute> \<sharp> P \<Longrightarrow> $ok\<acute> \<sharp> R3c_pre(P)"
  by (simp add: R3c_pre_def cond_def unrest)

lemma unrest_ok_R3c_post [unrest]: "$ok \<sharp> P \<Longrightarrow> $ok \<sharp> R3c_post(P)"
  by (simp add: R3c_post_def cond_def unrest)

lemma unrest_ok_R3c_post' [unrest]: "$ok\<acute> \<sharp> P \<Longrightarrow> $ok\<acute> \<sharp> R3c_post(P)"
  by (simp add: R3c_post_def cond_def unrest)

lemma unrest_ok_R3h_post [unrest]: "$ok \<sharp> P \<Longrightarrow> $ok \<sharp> R3h_post(P)"
  by (simp add: R3h_post_def cond_def unrest)

lemma unrest_ok_R3h_post' [unrest]: "$ok\<acute> \<sharp> P \<Longrightarrow> $ok\<acute> \<sharp> R3h_post(P)"
  by (simp add: R3h_post_def cond_def unrest)

lemma R3c_R1_design_composition: 
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q" "$ok \<sharp> R" "$ok \<sharp> S"
  shows "(R3c(R1(P \<turnstile> Q)) ;; R3c(R1(R \<turnstile> S))) = 
       R3c(R1((\<not> (R1(\<not> P) ;; R1(true)) \<and> \<not> ((R1(Q) \<and> \<not> $wait\<acute>) ;; R1(\<not> R))) 
       \<turnstile> (R1(Q) ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1(S)))))"
proof -
  have 1:"(\<not> (R1 (\<not> R3c_pre P) ;; R1 true)) = (R3c_pre (\<not> (R1 (\<not> P) ;; R1 true)))"
    by (rel_auto)
  have 2:"(\<not> (R1 (R3c_post Q) ;; R1 (\<not> R3c_pre R))) = R3c_pre(\<not> (R1 Q \<and> \<not> $wait\<acute> ;; R1 (\<not> R)))"
    by (rel_auto)
  have 3:"(R1 (R3c_post Q) ;; R1 (R3c_post S)) = R3c_post (R1 Q ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 S))"
    by (rel_auto)
  show ?thesis
    apply (simp add: R3c_semir_form R1_R3c_commute[THEN sym] R1_R3c_design unrest )
    apply (subst R1_design_composition)
    apply (simp_all add: unrest assms R3c_pre_conj 1 2 3)
  done
qed

lemma R3h_R1_design_composition: 
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q" "$ok \<sharp> R" "$ok \<sharp> S"
  shows "(R3h(R1(P \<turnstile> Q)) ;; R3h(R1(R \<turnstile> S))) = 
       R3h(R1((\<not> (R1(\<not> P) ;; R1(true)) \<and> \<not> ((R1(Q) \<and> \<not> $wait\<acute>) ;; R1(\<not> R))) 
       \<turnstile> (R1(Q) ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1(S)))))"
proof -
  have 1:"(\<not> (R1 (\<not> R3c_pre P) ;; R1 true)) = (R3c_pre (\<not> (R1 (\<not> P) ;; R1 true)))"
   by (rel_auto, blast+)
  have 2:"(\<not> (R1 (R3h_post Q) ;; R1 (\<not> R3c_pre R))) = R3c_pre(\<not> (R1 Q \<and> \<not> $wait\<acute> ;; R1 (\<not> R)))"
    by (rel_auto, blast+)
  have 3:"(R1 (R3h_post Q) ;; R1 (R3h_post S)) = R3h_post (R1 Q ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 S))"
    by (rel_auto, blast+)
  show ?thesis
    apply (simp add: R3h_semir_form R1_R3h_commute[THEN sym] R1_R3h_design unrest )
    apply (subst R1_design_composition)
    apply (simp_all add: unrest assms R3c_pre_conj 1 2 3)
  done
qed

lemma R1_des_lift_skip: "R1(\<lceil>II\<rceil>\<^sub>D) = \<lceil>II\<rceil>\<^sub>D"
  by (rel_auto)

lemma R2s_subst_wait_true [usubst]:
  "(R2s(P))\<lbrakk>true/$wait\<rbrakk> = R2s(P\<lbrakk>true/$wait\<rbrakk>)"
  by (simp add: R2s_def usubst unrest)

lemma R2s_subst_wait'_true [usubst]:
  "(R2s(P))\<lbrakk>true/$wait\<acute>\<rbrakk> = R2s(P\<lbrakk>true/$wait\<acute>\<rbrakk>)"
  by (simp add: R2s_def usubst unrest)

lemma R2_subst_wait_true [usubst]:
  "(R2(P))\<lbrakk>true/$wait\<rbrakk> = R2(P\<lbrakk>true/$wait\<rbrakk>)"
  by (simp add: R2_def R1_def R2s_def usubst unrest)

lemma R2_subst_wait'_true [usubst]:
  "(R2(P))\<lbrakk>true/$wait\<acute>\<rbrakk> = R2(P\<lbrakk>true/$wait\<acute>\<rbrakk>)"
  by (simp add: R2_def R1_def R2s_def usubst unrest)

lemma R2_subst_wait_false [usubst]:
  "(R2(P))\<lbrakk>false/$wait\<rbrakk> = R2(P\<lbrakk>false/$wait\<rbrakk>)"
  by (simp add: R2_def R1_def R2s_def usubst unrest)

lemma R2_subst_wait'_false [usubst]:
  "(R2(P))\<lbrakk>false/$wait\<acute>\<rbrakk> = R2(P\<lbrakk>false/$wait\<acute>\<rbrakk>)"
  by (simp add: R2_def R1_def R2s_def usubst unrest)

lemma R2_des_lift_skip:
  "R2(\<lceil>II\<rceil>\<^sub>D) = \<lceil>II\<rceil>\<^sub>D"
  by (rel_auto, metis alpha_rp'.cases_scheme alpha_rp'.select_convs(2) alpha_rp'.update_convs(2)  minus_zero_eq)

lemma R2c_R2s_absorb: "R2c(R2s(P)) = R2s(P)"
  by (rel_auto)

lemma R2_design_composition: 
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q" "$ok \<sharp> R" "$ok \<sharp> S"
  shows "(R2(P \<turnstile> Q) ;; R2(R \<turnstile> S)) = 
       R2((\<not> (R1 (\<not> R2c P) ;; R1 true) \<and> \<not> (R1 (R2c Q) ;; R1 (\<not> R2c R))) \<turnstile> (R1 (R2c Q) ;; R1 (R2c S)))"
  apply (simp add: R2_R2c_def R2c_design R1_design_composition assms unrest R2c_not R2c_and R2c_disj R1_R2c_commute[THEN sym] R2c_idem R2c_R1_seq)
  apply (metis (no_types, lifting) R2c_R1_seq R2c_not R2c_true)
done

lemma RH_design_composition: 
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q" "$ok \<sharp> R" "$ok \<sharp> S"
  shows "(RH(P \<turnstile> Q) ;; RH(R \<turnstile> S)) = 
       RH((\<not> (R1 (\<not> R2s P) ;; R1 true) \<and> \<not> (R1 (R2s Q) \<and> (\<not> $wait\<acute>) ;; R1 (\<not> R2s R))) \<turnstile>
                       (R1 (R2s Q) ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S))))"
proof -
  have 1: "R2c (R1 (\<not> R2s P) ;; R1 true) = (R1 (\<not> R2s P) ;; R1 true)"
  proof -
    have 1:"(R1 (\<not> R2s P) ;; R1 true) = (R1(R2 (\<not> P) ;; R2 true))"
      by (rel_auto)
    have "R2c(R1(R2 (\<not> P) ;; R2 true)) = R2c(R1(R2 (\<not> P) ;; R2 true))"
      using R2c_not by blast
    also have "... = R2(R2 (\<not> P) ;; R2 true)"
      by (metis R1_R2c_commute R1_R2c_is_R2)
    also have "... = (R2 (\<not> P) ;; R2 true)"
      by (simp add: R2_seqr_distribute)
    also have "... = (R1 (\<not> R2s P) ;; R1 true)"
      by (simp add: R2_def R2s_not R2s_true)
    finally show ?thesis
      by (simp add: 1)
  qed

  have 2:"R2c (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R)) = (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R))"
  proof -
    have "(R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R)) = R1 (R2 (Q \<and> \<not> $wait\<acute>) ;; R2 (\<not> R))"
      by (rel_auto)
    hence "R2c (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R)) = (R2 (Q \<and> \<not> $wait\<acute>) ;; R2 (\<not> R))"
      by (metis R1_R2c_commute R1_R2c_is_R2 R2_seqr_distribute)
    also have "... = (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R))"
      by rel_auto
    finally show ?thesis .
  qed

  have 3:"R2c((R1 (R2s Q) ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S)))) = (R1 (R2s Q) ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S)))"
  proof -
    have "R2c(((R1 (R2s Q))\<lbrakk>true/$wait\<acute>\<rbrakk> ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>true/$wait\<rbrakk>))
          = ((R1 (R2s Q))\<lbrakk>true/$wait\<acute>\<rbrakk> ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>true/$wait\<rbrakk>)"
    proof -
      have "R2c(((R1 (R2s Q))\<lbrakk>true/$wait\<acute>\<rbrakk> ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>true/$wait\<rbrakk>)) = 
            R2c(R1 (R2s (Q\<lbrakk>true/$wait\<acute>\<rbrakk>)) ;; \<lceil>II\<rceil>\<^sub>D\<lbrakk>true/$wait\<rbrakk>)"
        by (simp add: usubst cond_unit_T R1_def R2s_def)
      also have "... = R2c(R2(Q\<lbrakk>true/$wait\<acute>\<rbrakk>) ;; R2(\<lceil>II\<rceil>\<^sub>D\<lbrakk>true/$wait\<rbrakk>))"
        by (metis R2_def R2_des_lift_skip R2_subst_wait_true)
      also have "... = (R2(Q\<lbrakk>true/$wait\<acute>\<rbrakk>) ;; R2(\<lceil>II\<rceil>\<^sub>D\<lbrakk>true/$wait\<rbrakk>))"
        using R2c_seq by blast
      also have "... = ((R1 (R2s Q))\<lbrakk>true/$wait\<acute>\<rbrakk> ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>true/$wait\<rbrakk>)"
        apply (simp add: usubst R2_des_lift_skip)
        apply (metis R2_def R2_des_lift_skip R2_subst_wait'_true R2_subst_wait_true)
      done
      finally show ?thesis .
    qed
    moreover have "R2c(((R1 (R2s Q))\<lbrakk>false/$wait\<acute>\<rbrakk> ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>false/$wait\<rbrakk>))
          = ((R1 (R2s Q))\<lbrakk>false/$wait\<acute>\<rbrakk> ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>false/$wait\<rbrakk>)"
      by (simp add: usubst cond_unit_F, metis R2_R1_form R2_subst_wait'_false R2_subst_wait_false R2c_seq)
    ultimately show ?thesis
      by (smt R2_R1_form R2_condr' R2_des_lift_skip R2c_seq R2s_wait)
  qed

  have "(R1(R2s(R3c(P \<turnstile> Q))) ;; R1(R2s(R3c(R \<turnstile> S)))) =
        ((R3c(R1(R2s(P) \<turnstile> R2s(Q)))) ;; R3c(R1(R2s(R) \<turnstile> R2s(S))))"
    by (metis (no_types, hide_lams) R1_R2s_R2c R1_R3c_commute R2c_R3c_commute R2s_design)
  also have "... = R3c (R1 ((\<not> (R1 (\<not> R2s P) ;; R1 true) \<and> \<not> (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R))) \<turnstile>
                       (R1 (R2s Q) ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S)))))"
    by (simp add: R3c_R1_design_composition assms unrest)
  also have "... = R3c(R1(R2c((\<not> (R1 (\<not> R2s P) ;; R1 true) \<and> \<not> (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R))) \<turnstile>
                              (R1 (R2s Q) ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S))))))"
    by (simp add: R2c_design R2c_and R2c_not 1 2 3)
  finally show ?thesis
    by (simp add: R1_R2s_R2c R1_R3c_commute R2c_R3c_commute RH_R2c_def)
qed

lemma R2_st_ex: "R2 (\<exists> $st \<bullet> P) = (\<exists> $st \<bullet> R2(P))"
  by (rel_auto)

lemma RHS_design_composition: 
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q" "$ok \<sharp> R" "$ok \<sharp> S"
  shows "(\<^bold>R\<^sub>s(P \<turnstile> Q) ;; \<^bold>R\<^sub>s(R \<turnstile> S)) = 
       \<^bold>R\<^sub>s((\<not> (R1 (\<not> R2s P) ;; R1 true) \<and> \<not> (R1 (R2s Q) \<and> (\<not> $wait\<acute>) ;; R1 (\<not> R2s R))) \<turnstile>
                       (R1 (R2s Q) ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 (R2s S))))"
proof -
  have 1: "R2c (R1 (\<not> R2s P) ;; R1 true) = (R1 (\<not> R2s P) ;; R1 true)"
  proof -
    have 1:"(R1 (\<not> R2s P) ;; R1 true) = (R1(R2 (\<not> P) ;; R2 true))"
      by (rel_auto, blast)
    have "R2c(R1(R2 (\<not> P) ;; R2 true)) = R2c(R1(R2 (\<not> P) ;; R2 true))"
      using R2c_not by blast
    also have "... = R2(R2 (\<not> P) ;; R2 true)"
      by (metis R1_R2c_commute R1_R2c_is_R2)
    also have "... = (R2 (\<not> P) ;; R2 true)"
      by (simp add: R2_seqr_distribute)
    also have "... = (R1 (\<not> R2s P) ;; R1 true)"
      by (simp add: R2_def R2s_not R2s_true)
    finally show ?thesis
      by (simp add: 1)
  qed

  have 2:"R2c (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R)) = (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R))"
  proof -
    have "(R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R)) = R1 (R2 (Q \<and> \<not> $wait\<acute>) ;; R2 (\<not> R))"
      by (rel_auto, blast+)
    hence "R2c (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R)) = (R2 (Q \<and> \<not> $wait\<acute>) ;; R2 (\<not> R))"
      by (metis (no_types, lifting) R1_R2c_commute R1_R2c_is_R2 R2_seqr_distribute)
    also have "... = (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R))"
      by (rel_auto, blast+)
    finally show ?thesis .
  qed

  have 3:"R2c((R1 (R2s Q) ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 (R2s S)))) = 
          (R1 (R2s Q) ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 (R2s S)))"
  proof -
    have "R2c(((R1 (R2s Q))\<lbrakk>true/$wait\<acute>\<rbrakk> ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>true/$wait\<rbrakk>))
          = ((R1 (R2s Q))\<lbrakk>true/$wait\<acute>\<rbrakk> ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>true/$wait\<rbrakk>)"
    proof -
      have "R2c(((R1 (R2s Q))\<lbrakk>true/$wait\<acute>\<rbrakk> ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>true/$wait\<rbrakk>)) = 
            R2c(R1 (R2s (Q\<lbrakk>true/$wait\<acute>\<rbrakk>)) ;; (\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>true/$wait\<rbrakk>)"
        by (simp add: usubst cond_unit_T R1_def R2s_def)
      also have "... = R2c(R2(Q\<lbrakk>true/$wait\<acute>\<rbrakk>) ;; R2((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>true/$wait\<rbrakk>))"
        by (metis (no_types, lifting) R2_def R2_des_lift_skip R2_subst_wait_true R2_st_ex)
      also have "... = (R2(Q\<lbrakk>true/$wait\<acute>\<rbrakk>) ;; R2((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D)\<lbrakk>true/$wait\<rbrakk>))"
        using R2c_seq by blast
      also have "... = ((R1 (R2s Q))\<lbrakk>true/$wait\<acute>\<rbrakk> ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>true/$wait\<rbrakk>)"
        apply (simp add: usubst R2_des_lift_skip)
        apply (metis (no_types) R2_def R2_des_lift_skip R2_st_ex R2_subst_wait'_true R2_subst_wait_true)
      done
      finally show ?thesis .
    qed
    moreover have "R2c(((R1 (R2s Q))\<lbrakk>false/$wait\<acute>\<rbrakk> ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>false/$wait\<rbrakk>))
          = ((R1 (R2s Q))\<lbrakk>false/$wait\<acute>\<rbrakk> ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 (R2s S))\<lbrakk>false/$wait\<rbrakk>)"
      by (simp add: usubst, metis (no_types, lifting) R2_R1_form R2_subst_wait'_false R2_subst_wait_false R2c_seq)
    ultimately show ?thesis
      by (smt R2_R1_form R2_condr' R2_des_lift_skip R2_st_ex R2c_seq R2s_wait)
  qed

  have "(R1(R2s(R3h(P \<turnstile> Q))) ;; R1(R2s(R3h(R \<turnstile> S)))) =
        ((R3h(R1(R2s(P) \<turnstile> R2s(Q)))) ;; R3h(R1(R2s(R) \<turnstile> R2s(S))))"
    by (metis (no_types, hide_lams) R1_R2s_R2c R1_R3h_commute R2c_R3h_commute R2s_design)
  also have "... = R3h (R1 ((\<not> (R1 (\<not> R2s P) ;; R1 true) \<and> \<not> (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R))) \<turnstile>
                       (R1 (R2s Q) ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 (R2s S)))))"
    by (simp add: R3h_R1_design_composition assms unrest)
  also have "... = R3h(R1(R2c((\<not> (R1 (\<not> R2s P) ;; R1 true) \<and> \<not> (R1 (R2s Q) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R))) \<turnstile>
                              (R1 (R2s Q) ;; ((\<exists> $st \<bullet> \<lceil>II\<rceil>\<^sub>D) \<triangleleft> $wait \<triangleright> R1 (R2s S))))))"
    by (simp add: R2c_design R2c_and R2c_not 1 2 3)
  finally show ?thesis
    by (simp add: R1_R2s_R2c R1_R3h_commute R2c_R3h_commute RHS_R2c_def)
qed

lemma RH_design_export_R1: "RH(P \<turnstile> Q) = RH(P \<turnstile> R1(Q))"
  by (rel_auto)

lemma RH_design_export_R2s: "RH(P \<turnstile> Q) = RH(P \<turnstile> R2s(Q))"
  by (rel_auto)

lemma RH_design_export_R2: "RH(P \<turnstile> Q) = RH(P \<turnstile> R2(Q))"
  by (metis R2_def RH_design_export_R1 RH_design_export_R2s)

lemma RH_design_pre_neg_R1: "RH((\<not> R1 P) \<turnstile> Q) = RH((\<not> P) \<turnstile> Q)"
  by (metis (no_types, lifting) R1_R2c_commute R1_R3c_commute R1_def R1_disj RH_R2c_def design_def impl_alt_def not_conj_deMorgans utp_pred.double_compl utp_pred.inf.orderE utp_pred.inf_le2)
  
lemma RH_design_pre_R2s: "RH((R2s P) \<turnstile> Q) = RH(P \<turnstile> Q)"
  by (metis (no_types, lifting) R1_R2c_is_R2 R1_R2s_R2c R2_R3c_commute R2s_design R2s_idem RH_alt_def')

lemma RH_design_pre_R2c: "RH((R2c P) \<turnstile> Q) = RH(P \<turnstile> Q)"
  by (metis (no_types, lifting) R2c_design R2c_idem RH_absorbs_R2c)

lemma RH_design_pre_neg_R1_R2c: "RH((\<not> R1 (R2c P)) \<turnstile> Q) = RH((\<not> P) \<turnstile> Q)"
  by (simp add: RH_design_pre_neg_R1, metis R2c_not RH_design_pre_R2c)

lemma RH_design_refine_intro:
  assumes "`P\<^sub>1 \<Rightarrow> P\<^sub>2`" "`P\<^sub>1 \<and> Q\<^sub>2 \<Rightarrow> Q\<^sub>1`"
  shows "RH(P\<^sub>1 \<turnstile> Q\<^sub>1) \<sqsubseteq> RH(P\<^sub>2 \<turnstile> Q\<^sub>2)"
  by (simp add: RH_monotone assms(1) assms(2) design_refine_intro)

text {* Marcel's proof for reactive design composition *}

method rel_auto' = ((simp add: upred_defs urel_defs)?, (transfer, (rule_tac ext)?, auto simp add: uvar_defs lens_defs urel_defs relcomp_unfold fun_eq_iff prod.case_eq_if)?)

lemma reactive_design_composition:
  assumes "out\<alpha> \<sharp> p\<^sub>1" "p\<^sub>1 is R2s" "P\<^sub>2 is R2s" "Q\<^sub>1 is R2s" "Q\<^sub>2 is R2s"
  shows
  "(RH(p\<^sub>1 \<turnstile> Q\<^sub>1) ;; RH(P\<^sub>2 \<turnstile> Q\<^sub>2)) = 
    RH((p\<^sub>1 \<and> \<not> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; R1 (\<not> P\<^sub>2)))
       \<turnstile> ((($wait\<acute> \<and> Q\<^sub>1) \<or> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; R1(Q\<^sub>2)))))" (is "?lhs = ?rhs")
proof -
  have "?lhs = RH(?lhs)"
    by (metis Healthy_def' RH_idem RH_seq_closure)
  also have "... = RH ((R2 \<circ> R1) (p\<^sub>1 \<turnstile> Q\<^sub>1) ;; RH (P\<^sub>2 \<turnstile> Q\<^sub>2))"
    by (metis (no_types, hide_lams) R1_R2_commute R1_idem R2_R3c_commute R2_def R2_seqr_distribute R3c_semir_form RH_alt_def' calculation comp_apply)
  also have "... = RH (R1 ((\<not> $ok \<or> R2s (\<not> p\<^sub>1)) \<or> $ok\<acute> \<and> R2s Q\<^sub>1) ;; RH(P\<^sub>2 \<turnstile> Q\<^sub>2))"
    by (simp add: design_def R2_R1_form impl_alt_def R2s_not R2s_ok R2s_disj R2s_conj R2s_ok')
  also have "... = RH(((\<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; RH(P\<^sub>2 \<turnstile> Q\<^sub>2))
                      \<or> ((\<not> R2s(p\<^sub>1) \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; RH(P\<^sub>2 \<turnstile> Q\<^sub>2))
                      \<or> (($ok\<acute> \<and> R2s(Q\<^sub>1) \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; RH(P\<^sub>2 \<turnstile> Q\<^sub>2)))"
    by (smt R1_conj R1_def R1_disj R1_negate_R1 R2_def R2s_not seqr_or_distl utp_pred.conj_assoc utp_pred.inf.commute utp_pred.sup.assoc)
  also have "... = RH(((\<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; RH(P\<^sub>2 \<turnstile> Q\<^sub>2))
                      \<or> ((\<not> p\<^sub>1 \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; RH(P\<^sub>2 \<turnstile> Q\<^sub>2))
                      \<or> (($ok\<acute> \<and> Q\<^sub>1 \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; RH(P\<^sub>2 \<turnstile> Q\<^sub>2)))"
    by (metis Healthy_def' assms(2) assms(4))

  also have "... = RH((\<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>)
                      \<or> (\<not> p\<^sub>1 \<and> $tr \<le>\<^sub>u $tr\<acute>)
                      \<or> (($ok\<acute> \<and> Q\<^sub>1 \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; RH(P\<^sub>2 \<turnstile> Q\<^sub>2)))"
  proof -
    have "((\<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; RH(P\<^sub>2 \<turnstile> Q\<^sub>2)) = (\<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>)"
      by (rel_auto)
    moreover have "(((\<not> p\<^sub>1 ;; true) \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; RH(P\<^sub>2 \<turnstile> Q\<^sub>2)) = ((\<not> p\<^sub>1 ;; true) \<and> $tr \<le>\<^sub>u $tr\<acute>)"
      by (rel_auto)
    ultimately show ?thesis
      by (smt assms(1) precond_right_unit unrest_not)
  qed

  also have "... = RH((\<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>)
                      \<or> (\<not> p\<^sub>1 \<and> $tr \<le>\<^sub>u $tr\<acute>)
                      \<or> (($ok\<acute> \<and> Q\<^sub>1 \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; ($wait \<and> $ok\<acute> \<and> II))
                      \<or> (($ok\<acute> \<and> Q\<^sub>1 \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; (\<not> $wait \<and> R1(\<not> P\<^sub>2) \<and> $tr \<le>\<^sub>u $tr\<acute>))
                      \<or> (($ok\<acute> \<and> Q\<^sub>1 \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; (\<not> $wait \<and> $ok\<acute> \<and> R2(Q\<^sub>2) \<and> $tr \<le>\<^sub>u $tr\<acute>)))"
  proof -
    have 1:"RH(P\<^sub>2 \<turnstile> Q\<^sub>2) = (($wait \<and> \<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>)
                        \<or> ($wait \<and> $ok\<acute> \<and> II)
                        \<or> (\<not> $wait \<and> \<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>)
                        \<or> (\<not> $wait \<and> R2(\<not> P\<^sub>2) \<and> $tr \<le>\<^sub>u $tr\<acute>)
                        \<or> (\<not> $wait \<and> $ok\<acute> \<and> R2(Q\<^sub>2) \<and> $tr \<le>\<^sub>u $tr\<acute>))"
      by (simp add: RH_alt_def' R2_condr' R2s_wait R2_skip_rea R3c_def usubst, rel_auto)
    have 2:"(($ok\<acute> \<and> Q\<^sub>1 \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; ($wait \<and> \<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>)) = false"
      by rel_auto
    have 3:"(($ok\<acute> \<and> Q\<^sub>1 \<and> $tr \<le>\<^sub>u $tr\<acute>) ;; (\<not> $wait \<and> \<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>)) = false"
      by rel_auto
    have 4:"R2(\<not> P\<^sub>2) = R1(\<not> P\<^sub>2)"
      by (metis Healthy_def' R1_negate_R1 R2_def R2s_not assms(3))
    show ?thesis
      by (simp add: "1" "2" "3" "4" seqr_or_distr)
  qed
  
  also have "... = RH((\<not> $ok) \<or> (\<not> p\<^sub>1)
                      \<or> (($ok\<acute> \<and> Q\<^sub>1) ;; ($wait \<and> $ok\<acute> \<and> II))
                      \<or> (($ok\<acute> \<and> Q\<^sub>1) ;; (\<not> $wait \<and> R1(\<not> P\<^sub>2)))
                      \<or> (($ok\<acute> \<and> Q\<^sub>1) ;; (\<not> $wait \<and> $ok\<acute> \<and> R2(Q\<^sub>2))))"
    by (rel_blast)

  also have "... = RH((\<not> $ok) \<or> (\<not> p\<^sub>1)
                      \<or> ($ok\<acute> \<and> $wait\<acute> \<and> Q\<^sub>1)
                      \<or> (($ok\<acute> \<and> Q\<^sub>1) ;; (\<not> $wait \<and> R1(\<not> P\<^sub>2)))
                      \<or> (($ok\<acute> \<and> Q\<^sub>1) ;; (\<not> $wait \<and> $ok\<acute> \<and> R1(Q\<^sub>2))))"
  proof -
    have "(($ok\<acute> \<and> Q\<^sub>1) ;; ($wait \<and> $ok\<acute> \<and> II)) = ($ok\<acute> \<and> $wait\<acute> \<and> Q\<^sub>1)"
      by (rel_auto)
    moreover have "R2(Q\<^sub>2) = R1(Q\<^sub>2)"
      by (metis Healthy_def' R2_def assms(5))
    ultimately show ?thesis by simp
  qed

  also have "... = RH((\<not> $ok) \<or> (\<not> p\<^sub>1)
                      \<or> ($ok\<acute> \<and> $wait\<acute> \<and> Q\<^sub>1)
                      \<or> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; (R1(\<not> P\<^sub>2)))
                      \<or> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; ($ok\<acute> \<and> R1(Q\<^sub>2))))"
    by rel_auto'

  also have "... = RH((\<not> $ok) \<or> (\<not> p\<^sub>1) \<or> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; R1(\<not> P\<^sub>2))
                      \<or> ($ok\<acute> \<and> (($wait\<acute> \<and> Q\<^sub>1) \<or> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; R1(Q\<^sub>2)))))"
    by rel_auto'

  also have "... = RH(\<not> ($ok \<and> p\<^sub>1 \<and> \<not> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; R1(\<not> P\<^sub>2)))
                      \<or> ($ok\<acute> \<and> (($wait\<acute> \<and> Q\<^sub>1) \<or> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; R1(Q\<^sub>2)))))"
    by rel_auto'

  also have "... = ?rhs"
  proof -
    have "(\<not> ($ok \<and> p\<^sub>1 \<and> \<not> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; R1(\<not> P\<^sub>2)))
                      \<or> ($ok\<acute> \<and> (($wait\<acute> \<and> Q\<^sub>1) \<or> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; R1(Q\<^sub>2)))))
          = (($ok \<and> (p\<^sub>1 \<and> \<not> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; R1(\<not> P\<^sub>2)))) \<Rightarrow> 
            ($ok\<acute> \<and> (($wait\<acute> \<and> Q\<^sub>1) \<or> (($ok\<acute> \<and> \<not> $wait\<acute> \<and> Q\<^sub>1) ;; R1(Q\<^sub>2)))))"  
      by pred_auto
    thus ?thesis
      by (simp add: design_def)
  qed

  finally show ?thesis .
qed

subsection {* Healthiness conditions *}

definition [upred_defs]: "CSP1(P) = (P \<or> (\<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>))"

text {* CSP2 is just H2 since the type system will automatically have J identifying the reactive
        variables as required. *}

definition [upred_defs]: "CSP2(P) = H2(P)"

abbreviation "CSP(P) \<equiv> CSP1(CSP2(RH(P)))"

lemma CSP1_idem:
  "CSP1(CSP1(P)) = CSP1(P)"
  by pred_auto

lemma CSP2_idem:
  "CSP2(CSP2(P)) = CSP2(P)"
  by (simp add: CSP2_def H2_idem)

lemma CSP1_CSP2_commute:
  "CSP1(CSP2(P)) = CSP2(CSP1(P))"
  by (simp add: CSP1_def CSP2_def H2_split usubst, rel_auto)

lemma CSP1_R1_commute:
  "CSP1(R1(P)) = R1(CSP1(P))"
  by (rel_auto)

lemma CSP1_R2c_commute:
  "CSP1(R2c(P)) = R2c(CSP1(P))"
  by (rel_auto)

lemma CSP1_R3c_commute:
  "CSP1(R3c(P)) = R3c(CSP1(P))"
  by (rel_auto)

lemma CSP1_R3h_commute:
  "CSP1(R3h(P)) = R3h(CSP1(P))"
  by (rel_auto)

lemma CSP_idem: "CSP(CSP(P)) = CSP(P)"
  by (metis (no_types, hide_lams) CSP1_CSP2_commute CSP1_R1_commute CSP1_R2c_commute CSP1_R3c_commute CSP1_idem CSP2_def CSP2_idem R1_H2_commute R2c_H2_commute R3c_H2_commute RH_R2c_def RH_idem)

lemma CSP_Idempotent: "Idempotent CSP"
  by (simp add: CSP_idem Idempotent_def)

lemma CSP1_via_H1: "R1(H1(P)) = R1(CSP1(P))"
  by rel_auto

lemma CSP1_R3c: "CSP1(R3(P)) = R3c(CSP1(P))"
  by rel_auto

lemma CSP1_R1_H1: 
  "CSP1(R1(P)) = R1(H1(P))"
  by rel_auto

lemma CSP1_algebraic_intro:
  assumes 
    "P is R1" "(R1(true\<^sub>h) ;; P) = R1(true\<^sub>h)" "(II\<^sub>r ;; P) = P"
  shows "P is CSP1"
proof -
  have "P = (II\<^sub>r ;; P)"
    by (simp add: assms(3))
  also have "... = (R1($ok \<Rightarrow> II) ;; P)"
    by (simp add: skip_rea_R1_lemma)
  also have "... = (((\<not> $ok \<and> R1(true)) ;; P) \<or> P)"
    by (metis (no_types, lifting) R1_def seqr_left_unit seqr_or_distl skip_rea_R1_lemma skip_rea_def utp_pred.inf_top_left utp_pred.sup_commute)
  also have "... = (((R1(\<not> $ok) ;; R1(true\<^sub>h)) ;; P) \<or> P)"
    by (rel_auto, metis order_trans)
  also have "... = ((R1(\<not> $ok) ;; (R1(true\<^sub>h) ;; P)) \<or> P)"
    by (simp add: seqr_assoc)
  also have "... = ((R1(\<not> $ok) ;; R1(true\<^sub>h)) \<or> P)"
    by (simp add: assms(2))
  also have "... = (R1(\<not> $ok) \<or> P)"
    by (rel_auto)
  also have "... = CSP1(P)"
    by (rel_auto)
  finally show ?thesis 
    by (simp add: Healthy_def)
qed

theorem CSP1_left_zero:
  assumes "P is R1" "P is CSP1"
  shows "(R1(true) ;; P) = R1(true)"
proof -
  have "(R1(true) ;; R1(CSP1(P))) = R1(true)"
    by (rel_auto)
  thus ?thesis
    by (simp add: Healthy_if assms(1) assms(2))
qed

theorem CSP1_left_unit:
  assumes "P is R1" "P is CSP1"
  shows "(II\<^sub>r ;; P) = P"
proof -
  have "(II\<^sub>r ;; R1(CSP1(P))) = R1(CSP1(P))"
    by (rel_auto)
  thus ?thesis
    by (simp add: Healthy_if assms(1) assms(2))
qed

lemma CSP1_alt_def: 
  assumes "P is R1"
  shows "CSP1(P) = (P \<triangleleft> $ok \<triangleright> R1(true))"
  using assms
proof -
  have "CSP1(R1(P)) = (R1(P) \<triangleleft> $ok \<triangleright> R1(true))"
    by (rel_auto)
  thus ?thesis
    by (simp add: Healthy_if assms)
qed

theorem CSP1_algebraic:
  assumes "P is R1"
  shows "P is CSP1 \<longleftrightarrow> (R1(true\<^sub>h) ;; P) = R1(true\<^sub>h) \<and> (II\<^sub>r ;; P) = P"
  using CSP1_algebraic_intro CSP1_left_unit CSP1_left_zero assms by blast

lemma CSP1_reactive_design: "CSP1(RH(P \<turnstile> Q)) = RH(P \<turnstile> Q)"
  by rel_auto

lemma CSP2_reactive_design:
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q"
  shows "CSP2(RH(P \<turnstile> Q)) = RH(P \<turnstile> Q)"
  using assms
  by (simp add: CSP2_def H2_R1_comm H2_R2_comm H2_R3_comm H2_design RH_def H2_R2s_comm)

lemma wait_false_design:
  "(P \<turnstile> Q) \<^sub>f = ((P \<^sub>f) \<turnstile> (Q \<^sub>f))"
  by (rel_auto)

lemma CSP_RH_design_form:
  "CSP(P) = RH((\<not> P\<^sup>f\<^sub>f) \<turnstile> P\<^sup>t\<^sub>f)"
proof -
  have "CSP(P) = CSP1(CSP2(R1(R2s(R3c(P)))))"
    by (metis Healthy_def' RH_def assms)
  also have "... = CSP1(H2(R1(R2s(R3c(P)))))"
    by (simp add: CSP2_def)
  also have "... = CSP1(R1(H2(R2s(R3c(P)))))"
    by (simp add: R1_H2_commute)
  also have "... = R1(H1(R1(H2(R2s(R3c(P))))))"
    by (simp add: CSP1_R1_commute CSP1_via_H1 R1_idem)
  also have "... = R1(H1(H2(R2s(R3c(R1(P))))))"
    by (metis (no_types, hide_lams) CSP1_R1_H1 R1_H2_commute R1_R2_commute R1_idem R2_R3c_commute R2_def)
  also have "... = R1(R2s(H1(H2(R3c(R1(P))))))"
    by (simp add: R2s_H1_commute R2s_H2_commute)
  also have "... = R1(R2s(H1(R3c(H2(R1(P))))))"
    by (simp add: R3c_H2_commute)
  also have "... = R2(R1(H1(R3c(H2(R1(P))))))"
    by (metis R1_R2_commute R1_idem R2_def)
  also have "... = R2(R3c(R1(H1(H2(R1(P))))))"
    by (simp add: R1_H1_R3c_commute)
  also have "... = RH(H1_H2(R1(P)))"
    by (metis R1_R2_commute R1_idem R2_R3c_commute R2_def RH_def)
  also have "... = RH(H1_H2(P))"
    by (metis (no_types, hide_lams) CSP1_R1_H1 R1_H2_commute R1_R2_commute R1_R3c_commute R1_idem RH_alt_def)
  also have "... = RH((\<not> P\<^sup>f) \<turnstile> P\<^sup>t)"
  proof -
    have 0:"(\<not> (H1_H2(P))\<^sup>f) = ($ok \<and> \<not> P\<^sup>f)"
      by (simp add: H1_def H2_split, pred_auto)
    have 1:"(H1_H2(P))\<^sup>t = ($ok \<Rightarrow> (P\<^sup>f \<or> P\<^sup>t))"
      by (simp add: H1_def H2_split, pred_auto)
    have "(\<not> (H1_H2(P))\<^sup>f) \<turnstile> (H1_H2(P))\<^sup>t = ((\<not> P\<^sup>f) \<turnstile> P\<^sup>t)"
      by (simp add: 0 1, pred_auto)
    thus ?thesis
      by (metis H1_H2_commute H1_H2_is_design H1_idem H2_idem Healthy_def')
  qed
  also have "... = RH((\<not> P\<^sup>f\<^sub>f) \<turnstile> P\<^sup>t\<^sub>f)"
    by (metis (no_types, lifting) RH_subst_wait subst_not wait_false_design)
  finally show ?thesis .
qed

lemma CSP_reactive_design:
  assumes "P is CSP"
  shows "RH((\<not> P\<^sup>f\<^sub>f) \<turnstile> P\<^sup>t\<^sub>f) = P"
  by (metis CSP_RH_design_form Healthy_def' assms)

lemma CSP_RH_design: 
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q"
  shows "CSP(RH(P \<turnstile> Q)) = RH(P \<turnstile> Q)"
  by (metis CSP1_reactive_design CSP2_reactive_design RH_idem assms(1) assms(2))

lemma RH_design_is_CSP:
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q"
  shows "\<^bold>R(P \<turnstile> Q) is CSP"
  by (simp add: CSP_RH_design Healthy_def' assms(1) assms(2))

lemma CSP_R3_def: "CSP(P) = R1(R2c(\<^bold>H(R3(P))))"
  by (rel_auto)

lemma CSP2_R3c_commute: "CSP2(R3c(P)) = R3c(CSP2(P))"
  by (rel_auto)

lemma CSP2_R3h_commute: "CSP2(R3h(P)) = R3h(CSP2(P))"
  by (rel_auto)

lemma R3c_via_CSP1_R3:
  "\<lbrakk> P is CSP1; P is R3 \<rbrakk> \<Longrightarrow> P is R3c"
  by (metis CSP1_R3c Healthy_def')

lemma R3c_CSP1_form:
  "P is R1 \<Longrightarrow> R3c(CSP1(P)) = (R1(true) \<triangleleft> \<not>$ok \<triangleright> (II \<triangleleft> $wait \<triangleright> P))"
  by (rel_blast)

lemma R3c_CSP: "R3c(CSP(P)) = CSP(P)"
  by (simp add: CSP1_R3c_commute CSP2_R3c_commute R2_R3c_commute R3c_idem RH_alt_def')

lemma CSP_R1_R2s: "P is CSP \<Longrightarrow> R1 (R2s P) = P"
  by (metis (no_types) CSP_reactive_design R1_R2c_is_R2 R1_R2s_R2c R2_idem RH_alt_def')

lemma CSP_healths:
  assumes "P is CSP"
  shows "P is R1" "P is R2" "P is R3c" "P is CSP1" "P is CSP2"
  apply (metis (mono_tags) CSP_R1_R2s Healthy_def' R1_idem assms(1))
  apply (metis CSP_R1_R2s Healthy_def R2_def assms)
  apply (metis Healthy_def R3c_CSP assms)
  apply (metis CSP1_idem Healthy_def' assms)
  apply (metis CSP1_CSP2_commute CSP2_idem Healthy_def' assms)
done

lemma CSP_intro:
  assumes "P is R1" "P is R2" "P is R3c" "P is CSP1" "P is CSP2"
  shows "P is CSP"
  by (metis Healthy_def RH_alt_def' assms(2) assms(3) assms(4) assms(5))

subsection {* Reactive design triples *}

definition wait'_cond :: "_ \<Rightarrow> _ \<Rightarrow> _" (infix "\<diamondop>" 65) where
[upred_defs]: "P \<diamondop> Q = (P \<triangleleft> $wait\<acute> \<triangleright> Q)"

lemma wait'_cond_unrest [unrest]:
  "\<lbrakk> out_var wait \<bowtie> x; x \<sharp> P; x \<sharp> Q \<rbrakk> \<Longrightarrow> x \<sharp> (P \<diamondop> Q)"
  by (simp add: wait'_cond_def unrest)

lemma wait'_cond_subst [usubst]:
  "$wait\<acute> \<sharp> \<sigma> \<Longrightarrow> \<sigma> \<dagger> (P \<diamondop> Q) = (\<sigma> \<dagger> P) \<diamondop> (\<sigma> \<dagger> Q)"
  by (simp add: wait'_cond_def usubst unrest)

lemma wait'_cond_left_false: "false \<diamondop> P = (\<not> $wait\<acute> \<and> P)"
  by (rel_auto)

lemma wait'_cond_seq: "((P \<diamondop> Q) ;; R) = ((P ;; $wait \<and> R) \<or> (Q ;; \<not>$wait \<and> R))"
  by (simp add: wait'_cond_def cond_def seqr_or_distl, rel_blast)

lemma wait'_cond_true: "(P \<diamondop> Q \<and> $wait\<acute>) = (P \<and> $wait\<acute>)" 
  by (rel_auto)

lemma wait'_cond_false: "(P \<diamondop> Q \<and> (\<not>$wait\<acute>)) = (Q \<and> (\<not>$wait\<acute>))" 
  by (rel_auto)    

lemma wait'_cond_idem: "P \<diamondop> P = P"
  by (rel_auto)

lemma wait'_cond_conj_exchange:
  "((P \<diamondop> Q) \<and> (R \<diamondop> S)) = (P \<and> R) \<diamondop> (Q \<and> S)"
  by rel_auto

lemma subst_wait'_cond_true [usubst]: "(P \<diamondop> Q)\<lbrakk>true/$wait\<acute>\<rbrakk> = P\<lbrakk>true/$wait\<acute>\<rbrakk>"
  by rel_auto

lemma subst_wait'_cond_false [usubst]: "(P \<diamondop> Q)\<lbrakk>false/$wait\<acute>\<rbrakk> = Q\<lbrakk>false/$wait\<acute>\<rbrakk>"
  by rel_auto  

lemma subst_wait'_left_subst: "(P\<lbrakk>true/$wait\<acute>\<rbrakk> \<diamondop> Q) = (P \<diamondop> Q)"
  by (metis wait'_cond_def cond_def conj_comm conj_eq_out_var_subst upred_eq_true wait_vwb_lens)

lemma subst_wait'_right_subst: "(P \<diamondop> Q\<lbrakk>false/$wait\<acute>\<rbrakk>) = (P \<diamondop> Q)"
  by (metis cond_def conj_eq_out_var_subst upred_eq_false utp_pred.inf.commute wait'_cond_def wait_vwb_lens)

lemma wait'_cond_split: "P\<lbrakk>true/$wait\<acute>\<rbrakk> \<diamondop> P\<lbrakk>false/$wait\<acute>\<rbrakk> = P"
  by (simp add: wait'_cond_def cond_var_split)

lemma R1_wait'_cond: "R1(P \<diamondop> Q) = R1(P) \<diamondop> R1(Q)"
  by rel_auto

lemma R2s_wait'_cond: "R2s(P \<diamondop> Q) = R2s(P) \<diamondop> R2s(Q)"
  by (simp add: wait'_cond_def R2s_def R2s_def usubst)

lemma R2_wait'_cond: "R2(P \<diamondop> Q) = R2(P) \<diamondop> R2(Q)"
  by (simp add: R2_def R2s_wait'_cond R1_wait'_cond)

lemma RH_design_peri_R1: "RH(P \<turnstile> R1(Q) \<diamondop> R) = RH(P \<turnstile> Q \<diamondop> R)"
  by (metis (no_types, lifting) R1_idem R1_wait'_cond RH_design_export_R1)

lemma RH_design_post_R1: "RH(P \<turnstile> Q \<diamondop> R1(R)) = RH(P \<turnstile> Q \<diamondop> R)"
  by (metis R1_wait'_cond RH_design_export_R1 RH_design_peri_R1)

lemma RH_design_peri_R2s: "RH(P \<turnstile> R2s(Q) \<diamondop> R) = RH(P \<turnstile> Q \<diamondop> R)"
  by (metis (no_types, lifting) R2s_idem R2s_wait'_cond RH_design_export_R2s)

lemma RH_design_post_R2s: "RH(P \<turnstile> Q \<diamondop> R2s(R)) = RH(P \<turnstile> Q \<diamondop> R)"
  by (metis (no_types, lifting) R2s_idem R2s_wait'_cond RH_design_export_R2s)

lemma RH_design_peri_R2c: "RH(P \<turnstile> R2c(Q) \<diamondop> R) = RH(P \<turnstile> Q \<diamondop> R)"
  by (metis (no_types, lifting) R1_R2c_is_R2 R2_wait'_cond R2c_idem RH_design_export_R2)
  
lemma RH_design_post_R2c: "RH(P \<turnstile> Q \<diamondop> R2c(R)) = RH(P \<turnstile> Q \<diamondop> R)"
  by (metis (no_types, lifting) R1_R2c_is_R2 R2_wait'_cond R2c_idem RH_design_export_R2)

lemma RH_design_lemma1:
  "RH(P \<turnstile> (R1(R2c(Q)) \<or> R) \<diamondop> S) = RH(P \<turnstile> (Q \<or> R) \<diamondop> S)"
  by (simp add: design_def impl_alt_def wait'_cond_def RH_R2c_def R2c_R3c_commute R1_R3c_commute R1_disj R2c_disj R2c_and R1_cond R2c_condr R1_R2c_commute R2c_idem R1_extend_conj' R1_idem)

lemma RH_tri_design_composition: 
  assumes "$ok\<acute> \<sharp> P" "$ok\<acute> \<sharp> Q\<^sub>1" "$ok\<acute> \<sharp> Q\<^sub>2" "$ok \<sharp> R" "$ok \<sharp> S\<^sub>1" "$ok \<sharp> S\<^sub>2"
           "$wait\<acute> \<sharp> Q\<^sub>2" "$wait \<sharp> S\<^sub>1" "$wait \<sharp> S\<^sub>2"
  shows "(RH(P \<turnstile> Q\<^sub>1 \<diamondop> Q\<^sub>2) ;; RH(R \<turnstile> S\<^sub>1 \<diamondop> S\<^sub>2)) = 
       RH((\<not> (R1 (\<not> R2s P) ;; R1 true) \<and> \<not> (R1 (R2s Q\<^sub>2) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R))) \<turnstile>
                       ((Q\<^sub>1 \<or> (R1 (R2s Q\<^sub>2) ;; R1 (R2s S\<^sub>1))) \<diamondop> ((R1 (R2s Q\<^sub>2) ;; R1 (R2s S\<^sub>2)))))"
proof -
  have 1:"(\<not> (R1 (R2s (Q\<^sub>1 \<diamondop> Q\<^sub>2)) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R))) = 
        (\<not> (R1 (R2s Q\<^sub>2) \<and> \<not> $wait\<acute> ;; R1 (\<not> R2s R)))"
    by (metis (no_types, hide_lams) R1_extend_conj R2s_conj R2s_not R2s_wait' wait'_cond_false)
  have 2: "(R1 (R2s (Q\<^sub>1 \<diamondop> Q\<^sub>2)) ;; (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s (S\<^sub>1 \<diamondop> S\<^sub>2)))) =
                 ((R1 (R2s Q\<^sub>1) \<or> (R1 (R2s Q\<^sub>2) ;; R1 (R2s S\<^sub>1))) \<diamondop> (R1 (R2s Q\<^sub>2) ;; R1 (R2s S\<^sub>2)))"
  proof -
    have "(R1 (R2s Q\<^sub>1) ;; $wait \<and> (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S\<^sub>1) \<diamondop> R1 (R2s S\<^sub>2)))
                       = (R1 (R2s Q\<^sub>1) \<and> $wait\<acute>)"
    proof -
      have "(R1 (R2s Q\<^sub>1) ;; $wait \<and> (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S\<^sub>1) \<diamondop> R1 (R2s S\<^sub>2))) 
           = (R1 (R2s Q\<^sub>1) ;; $wait \<and> \<lceil>II\<rceil>\<^sub>D)"
        by (rel_auto)
      also have "... = ((R1 (R2s Q\<^sub>1) ;; \<lceil>II\<rceil>\<^sub>D) \<and> $wait\<acute>)"
        by (rel_auto)
      also from assms(2) have "... = ((R1 (R2s Q\<^sub>1)) \<and> $wait\<acute>)"
        by (simp add: lift_des_skip_dr_unit_unrest unrest)
      finally show ?thesis .
    qed
 
    moreover have "(R1 (R2s Q\<^sub>2) ;; \<not> $wait \<and> (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S\<^sub>1) \<diamondop> R1 (R2s S\<^sub>2)))
                  = ((R1 (R2s Q\<^sub>2)) ;; (R1 (R2s S\<^sub>1) \<diamondop> R1 (R2s S\<^sub>2)))"
    proof - 
      have "(R1 (R2s Q\<^sub>2) ;; \<not> $wait \<and> (\<lceil>II\<rceil>\<^sub>D \<triangleleft> $wait \<triangleright> R1 (R2s S\<^sub>1) \<diamondop> R1 (R2s S\<^sub>2)))
            = (R1 (R2s Q\<^sub>2) ;; \<not> $wait \<and> (R1 (R2s S\<^sub>1) \<diamondop> R1 (R2s S\<^sub>2)))"
        by (metis (no_types, lifting) cond_def conj_disj_not_abs utp_pred.double_compl utp_pred.inf.left_idem utp_pred.sup_assoc utp_pred.sup_inf_absorb)

      also have "... = ((R1 (R2s Q\<^sub>2))\<lbrakk>false/$wait\<acute>\<rbrakk> ;; (R1 (R2s S\<^sub>1) \<diamondop> R1 (R2s S\<^sub>2))\<lbrakk>false/$wait\<rbrakk>)"
        by (metis false_alt_def seqr_right_one_point upred_eq_false wait_vwb_lens)

      also have "... = ((R1 (R2s Q\<^sub>2)) ;; (R1 (R2s S\<^sub>1) \<diamondop> R1 (R2s S\<^sub>2)))"
        by (simp add: wait'_cond_def usubst unrest assms)
      
      finally show ?thesis .
    qed
      
    moreover
    have "((R1 (R2s Q\<^sub>1) \<and> $wait\<acute>) \<or> ((R1 (R2s Q\<^sub>2)) ;; (R1 (R2s S\<^sub>1) \<diamondop> R1 (R2s S\<^sub>2))))
          = (R1 (R2s Q\<^sub>1) \<or> (R1 (R2s Q\<^sub>2) ;; R1 (R2s S\<^sub>1))) \<diamondop> ((R1 (R2s Q\<^sub>2) ;; R1 (R2s S\<^sub>2)))"
      by (simp add: wait'_cond_def cond_seq_right_distr cond_and_T_integrate unrest)

    ultimately show ?thesis
      by (simp add: R2s_wait'_cond R1_wait'_cond wait'_cond_seq)
  qed

  show ?thesis
    apply (subst RH_design_composition)
    apply (simp_all add: assms)
    apply (simp add: assms wait'_cond_def unrest)
    apply (simp add: assms wait'_cond_def unrest)
    apply (simp add: 1 2)
    apply (simp add: R1_R2s_R2c RH_design_lemma1)
  done
qed

text {* Syntax for pre-, post-, and periconditions *}

abbreviation "pre\<^sub>s  \<equiv> [$ok \<mapsto>\<^sub>s true, $ok\<acute> \<mapsto>\<^sub>s false, $wait \<mapsto>\<^sub>s false]"
abbreviation "cmt\<^sub>s  \<equiv> [$ok \<mapsto>\<^sub>s true, $ok\<acute> \<mapsto>\<^sub>s true, $wait \<mapsto>\<^sub>s false]"
abbreviation "peri\<^sub>s \<equiv> [$ok \<mapsto>\<^sub>s true, $ok\<acute> \<mapsto>\<^sub>s true, $wait \<mapsto>\<^sub>s false, $wait\<acute> \<mapsto>\<^sub>s true]"
abbreviation "post\<^sub>s \<equiv> [$ok \<mapsto>\<^sub>s true, $ok\<acute> \<mapsto>\<^sub>s true, $wait \<mapsto>\<^sub>s false, $wait\<acute> \<mapsto>\<^sub>s false]"

abbreviation "npre\<^sub>R(P) \<equiv> pre\<^sub>s \<dagger> P"

definition [upred_defs]: "pre\<^sub>R(P)  = (\<not> (npre\<^sub>R(P)))" 
definition [upred_defs]: "cmt\<^sub>R(P)  = (cmt\<^sub>s \<dagger> P)"
definition [upred_defs]: "peri\<^sub>R(P) = (peri\<^sub>s \<dagger> P)"
definition [upred_defs]: "post\<^sub>R(P) = (post\<^sub>s \<dagger> P)"

lemma ok_pre_unrest [unrest]: "$ok \<sharp> pre\<^sub>R P"
  by (simp add: pre\<^sub>R_def unrest usubst)

lemma ok_peri_unrest [unrest]: "$ok \<sharp> peri\<^sub>R P"
  by (simp add: peri\<^sub>R_def unrest usubst)

lemma ok_post_unrest [unrest]: "$ok \<sharp> post\<^sub>R P"
  by (simp add: post\<^sub>R_def unrest usubst)

lemma ok'_pre_unrest [unrest]: "$ok\<acute> \<sharp> pre\<^sub>R P"
  by (simp add: pre\<^sub>R_def unrest usubst)

lemma ok'_peri_unrest [unrest]: "$ok\<acute> \<sharp> peri\<^sub>R P"
  by (simp add: peri\<^sub>R_def unrest usubst)

lemma ok'_post_unrest [unrest]: "$ok\<acute> \<sharp> post\<^sub>R P"
  by (simp add: post\<^sub>R_def unrest usubst)

lemma wait_pre_unrest [unrest]: "$wait \<sharp> pre\<^sub>R P"
  by (simp add: pre\<^sub>R_def unrest usubst)

lemma wait_peri_unrest [unrest]: "$wait \<sharp> peri\<^sub>R P"
  by (simp add: peri\<^sub>R_def unrest usubst)

lemma wait_post_unrest [unrest]: "$wait \<sharp> post\<^sub>R P"
  by (simp add: post\<^sub>R_def unrest usubst)

lemma wait'_peri_unrest [unrest]: "$wait\<acute> \<sharp> peri\<^sub>R P"
  by (simp add: peri\<^sub>R_def unrest usubst)

lemma wait'_post_unrest [unrest]: "$wait\<acute> \<sharp> post\<^sub>R P"
  by (simp add: post\<^sub>R_def unrest usubst)

lemma pre\<^sub>s_design: "pre\<^sub>s \<dagger> (P \<turnstile> Q) = (\<not> pre\<^sub>s \<dagger> P)"
  by (simp add: design_def pre\<^sub>R_def usubst)

lemma peri\<^sub>s_design: "peri\<^sub>s \<dagger> (P \<turnstile> Q \<diamondop> R) = peri\<^sub>s \<dagger> (P \<Rightarrow> Q)"
  by (simp add: design_def usubst wait'_cond_def)

lemma post\<^sub>s_design: "post\<^sub>s \<dagger> (P \<turnstile> Q \<diamondop> R) = post\<^sub>s \<dagger> (P \<Rightarrow> R)"
  by (simp add: design_def usubst wait'_cond_def)

lemma pre\<^sub>s_R1 [usubst]: "pre\<^sub>s \<dagger> R1(P) = R1(pre\<^sub>s \<dagger> P)"
  by (simp add: R1_def usubst)

lemma pre\<^sub>s_R2c [usubst]: "pre\<^sub>s \<dagger> R2c(P) = R2c(pre\<^sub>s \<dagger> P)"
  by (simp add: R2c_def R2s_def usubst)

lemma peri\<^sub>s_R1 [usubst]: "peri\<^sub>s \<dagger> R1(P) = R1(peri\<^sub>s \<dagger> P)"
  by (simp add: R1_def usubst)

lemma peri\<^sub>s_R2c [usubst]: "peri\<^sub>s \<dagger> R2c(P) = R2c(peri\<^sub>s \<dagger> P)"
  by (simp add: R2c_def R2s_def usubst)

lemma post\<^sub>s_R1 [usubst]: "post\<^sub>s \<dagger> R1(P) = R1(post\<^sub>s \<dagger> P)"
  by (simp add: R1_def usubst)

lemma post\<^sub>s_R2c [usubst]: "post\<^sub>s \<dagger> R2c(P) = R2c(post\<^sub>s \<dagger> P)"
  by (simp add: R2c_def R2s_def usubst)

lemma rea_pre_RH_design: "pre\<^sub>R(RH(P \<turnstile> Q)) = (\<not> R1(R2c(pre\<^sub>s \<dagger> (\<not> P))))"
  by (simp add: RH_R2c_def usubst R3c_def pre\<^sub>R_def pre\<^sub>s_design)

lemma rea_peri_RH_design: "peri\<^sub>R(RH(P \<turnstile> Q \<diamondop> R)) = R1(R2c(peri\<^sub>s \<dagger> (P \<Rightarrow> Q)))"
  by (simp add:RH_R2c_def usubst peri\<^sub>R_def R3c_def peri\<^sub>s_design)

lemma rea_post_RH_design: "post\<^sub>R(RH(P \<turnstile> Q \<diamondop> R)) = R1(R2c(post\<^sub>s \<dagger> (P \<Rightarrow> R)))"
  by (simp add:RH_R2c_def usubst post\<^sub>R_def R3c_def post\<^sub>s_design)

lemma CSP_reactive_tri_design_lemma:
  assumes "P is CSP"
  shows "RH((\<not> P\<^sup>f\<^sub>f) \<turnstile> P\<^sup>t\<^sub>f\<lbrakk>true/$wait\<acute>\<rbrakk> \<diamondop> P\<^sup>t\<^sub>f\<lbrakk>false/$wait\<acute>\<rbrakk>) = P"
  by (simp add: CSP_reactive_design assms wait'_cond_split)

lemma CSP_reactive_tri_design:
  assumes "P is CSP"
  shows "RH(pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P)) = P"
proof -
  have "P = RH((\<not> P\<^sup>f\<^sub>f) \<turnstile> P\<^sup>t\<^sub>f\<lbrakk>true/$wait\<acute>\<rbrakk> \<diamondop> P\<^sup>t\<^sub>f\<lbrakk>false/$wait\<acute>\<rbrakk>)"
    by (simp add: CSP_reactive_tri_design_lemma assms)
  also have "... = RH(pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P))"
    apply (simp add: usubst)
    apply (subst design_subst_ok_ok'[THEN sym])
    apply (simp add: pre\<^sub>R_def peri\<^sub>R_def post\<^sub>R_def usubst unrest)
  done
  finally show ?thesis ..
qed

lemma R1_neg_R2s_pre_RH:
  assumes "P is CSP"
  shows "R1 (\<not> R2s(pre\<^sub>R(P))) = (\<not> (pre\<^sub>R(P)))"
proof -
  have "(\<not> pre\<^sub>R(P)) = (\<not> pre\<^sub>R(RH(pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P))))"
    by (simp add: CSP_reactive_tri_design assms)
  also have "... = R1(R2s(\<not> pre\<^sub>R(RH(pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P)))))"
    by (rel_auto)
  also have "... = R1 (\<not> R2s(pre\<^sub>R(RH(pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P)))))"
    by (simp add: R2s_not)
  also have "... = R1 (\<not> R2s(pre\<^sub>R(P)))"
    by (simp add: CSP_reactive_tri_design assms)
  finally show ?thesis ..
qed

lemma R1_R2s_peri_RH:
  assumes "P is CSP"
  shows "R1(R2s(peri\<^sub>R(P))) = peri\<^sub>R(P)"
  by (metis (mono_tags, lifting) CSP_R1_R2s R1_R2s_R2c assms peri\<^sub>R_def peri\<^sub>s_R1 peri\<^sub>s_R2c)
  
lemma R1_R2s_post_RH:
  assumes "P is CSP"
  shows "R1(R2s(post\<^sub>R(P))) = post\<^sub>R(P)"
  by (metis (mono_tags, lifting) CSP_R1_R2s R1_R2s_R2c assms post\<^sub>R_def post\<^sub>s_R1 post\<^sub>s_R2c)

lemma CSP_composition:
  assumes "P is CSP" "Q is CSP"
  shows "(P ;; Q) = \<^bold>R ((\<not> (\<not> pre\<^sub>R P ;; R1 true) \<and> \<not> (post\<^sub>R P \<and> \<not> $wait\<acute> ;; \<not> pre\<^sub>R Q)) \<turnstile>
                       (peri\<^sub>R P \<or> (post\<^sub>R P ;; peri\<^sub>R Q)) \<diamondop> (post\<^sub>R P ;; post\<^sub>R Q))"
proof -
  have "(P ;; Q) = (\<^bold>R(pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P)) ;; \<^bold>R(pre\<^sub>R(Q) \<turnstile> peri\<^sub>R(Q) \<diamondop> post\<^sub>R(Q)))"
    by (simp add: CSP_reactive_tri_design assms(1) assms(2))
  also from assms have "... = \<^bold>R ((\<not> (\<not> pre\<^sub>R P ;; R1 true) \<and> \<not> (post\<^sub>R P \<and> \<not> $wait\<acute> ;; \<not> pre\<^sub>R Q)) \<turnstile>
        (peri\<^sub>R P \<or> (post\<^sub>R P ;; peri\<^sub>R Q)) \<diamondop> (post\<^sub>R P ;; post\<^sub>R Q))"
    by (simp add: RH_tri_design_composition unrest R1_R2s_peri_RH R1_R2s_post_RH R1_neg_R2s_pre_RH)
  finally show ?thesis .
qed

lemma CSP_seqr_closure:
  assumes "P is CSP" "Q is CSP"
  shows "(P ;; Q) is CSP"
proof -
  have "(P ;; Q) = \<^bold>R ((\<not> (\<not> pre\<^sub>R P ;; R1 true) \<and> \<not> (post\<^sub>R P \<and> \<not> $wait\<acute> ;; \<not> pre\<^sub>R Q)) \<turnstile>
                       (peri\<^sub>R P \<or> (post\<^sub>R P ;; peri\<^sub>R Q)) \<diamondop> (post\<^sub>R P ;; post\<^sub>R Q))"
    by (simp add: CSP_composition assms(1) assms(2))
  also have "... is CSP"
    by (simp add: RH_design_is_CSP add: unrest)
  finally show ?thesis .
qed 
                      
lemma skip_rea_reactive_design:
  "II\<^sub>r = RH(true \<turnstile> II)"
proof -
  have "RH(true \<turnstile> II) = R1(R2c(R3c(true \<turnstile> II)))"
    by (metis RH_R2c_def)
  also have "... = R1(R3c(R2c(true \<turnstile> II)))"
    by (metis R2c_R3c_commute RH_R2c_def)
  also have "... = R1(R3c(true \<turnstile> II))"
    by (simp add: design_def impl_alt_def R2c_disj R2c_not R2c_ok R2c_and R2c_skip_r R2c_ok')
  also have "... = R1(II\<^sub>r \<triangleleft> $wait \<triangleright> true \<turnstile> II)"
    by (metis R3c_def)
  also have "... = II\<^sub>r"
    by (rel_auto)
  finally show ?thesis ..
qed

lemma skip_rea_reactive_design':
  "II\<^sub>r = RH(true \<turnstile> \<lceil>II\<rceil>\<^sub>D)"
  by (metis aext_true rdesign_def skip_d_alt_def skip_d_def skip_rea_reactive_design)

lemma skip_rea_CSP1_skip: "II\<^sub>r = CSP1(II)"
  by (rel_auto)

lemma RH_design_subst_wait: "RH(P \<^sub>f \<turnstile> Q \<^sub>f) = RH(P \<turnstile> Q)"
  by (metis RH_subst_wait wait_false_design)

lemma RH_design_subst_wait_pre: "RH(P \<^sub>f \<turnstile> Q) = RH(P \<turnstile> Q)"
  by (subst RH_design_subst_wait[THEN sym], simp add: usubst RH_design_subst_wait)

lemma RH_design_subst_wait_post: "RH(P \<turnstile> Q \<^sub>f) = RH(P \<turnstile> Q)"
  by (subst RH_design_subst_wait[THEN sym], simp add: usubst RH_design_subst_wait)

lemma RH_peri_subst_false_wait: "RH(P \<turnstile> Q \<^sub>f \<diamondop> R) = RH(P \<turnstile> Q \<diamondop> R)"
  apply (subst RH_design_subst_wait_post[THEN sym])
  apply (simp add: usubst unrest)
  apply (metis RH_design_subst_wait RH_design_subst_wait_pre out_in_indep out_var_uvar unrest_false unrest_usubst_id unrest_usubst_upd vwb_lens.axioms(2) wait'_cond_subst wait_vwb_lens)
done

lemma RH_post_subst_false_wait: "RH(P \<turnstile> Q \<diamondop> R \<^sub>f) = RH(P \<turnstile> Q \<diamondop> R)"
  apply (subst RH_design_subst_wait_post[THEN sym])
  apply (simp add: usubst unrest)
  apply (metis RH_design_subst_wait RH_design_subst_wait_pre out_in_indep out_var_uvar unrest_false unrest_usubst_id unrest_usubst_upd vwb_lens.axioms(2) wait'_cond_subst wait_vwb_lens)
done

lemma skip_rea_reactive_tri_design:
  "II\<^sub>r = RH(true \<turnstile> false \<diamondop> \<lceil>II\<rceil>\<^sub>D)" (is "?lhs = ?rhs")
proof -
  have "?rhs = RH (true \<turnstile> (\<not> $wait\<acute> \<and> \<lceil>II\<rceil>\<^sub>D))"
    by (simp add: wait'_cond_def cond_def)
  have "... = RH (true \<turnstile> (\<not> $wait \<and> \<lceil>II\<rceil>\<^sub>D))" (is "RH (true \<turnstile> ?Q1) = RH (true \<turnstile> ?Q2)")
  proof -
    have "?Q1 = ?Q2"
      by (rel_auto)
    thus ?thesis by simp
  qed
  also have "... = RH (true \<turnstile> \<lceil>II\<rceil>\<^sub>D)"
    by (rel_auto)
  finally show ?thesis
    by (simp add: skip_rea_reactive_design' wait'_cond_def cond_def)
qed

lemma skip_d_lift_rea: 
  "\<lceil>II\<rceil>\<^sub>D = ($wait\<acute> =\<^sub>u $wait \<and> $tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R)"
  by (rel_auto)

lemma skip_rea_reactive_tri_design':
  "II\<^sub>r = RH(true \<turnstile> false \<diamondop> ($tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R))" (is "?lhs = ?rhs")
proof -
  have "?rhs = RH (true \<turnstile> (\<not> $wait\<acute> \<and> $tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R))"
    by (simp add: wait'_cond_def cond_def)
  also have "... = RH (true \<turnstile> ($wait\<acute> =\<^sub>u $wait \<and> $tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R))" (is "RH (true \<turnstile> ?Q1) = RH (true \<turnstile> ?Q2)")
  proof -
    have "?Q1 \<^sub>f = ?Q2 \<^sub>f"
      by (rel_auto)
    thus ?thesis
      by (metis RH_design_subst_wait)
  qed
  also have "... = RH (true \<turnstile> \<lceil>II\<rceil>\<^sub>D)"
    by (metis skip_d_lift_rea)
  finally show ?thesis
    by (simp add: skip_rea_reactive_design')
qed

lemma R1_neg_pre: "R1 (\<not> pre\<^sub>R P) = (\<not> pre\<^sub>R (R1(P)))"
  by (simp add: pre\<^sub>R_def R1_def usubst)

lemma R1_peri: "R1 (peri\<^sub>R P) = peri\<^sub>R (R1(P))"
  by (simp add: peri\<^sub>R_def R1_def usubst)

lemma R1_post: "R1 (post\<^sub>R P) = post\<^sub>R (R1(P))"
  by (simp add: post\<^sub>R_def R1_def usubst)

lemma R2s_pre:
  "R2s (pre\<^sub>R P) = pre\<^sub>R (R2s P)"
  by (simp add: pre\<^sub>R_def R2s_def usubst)

lemma R2s_peri: "R2s (peri\<^sub>R P) = peri\<^sub>R (R2s P)"
  by (simp add: peri\<^sub>R_def R2s_def usubst)

lemma R2s_post: "R2s (post\<^sub>R P) = post\<^sub>R (R2s P)"
  by (simp add: post\<^sub>R_def R2s_def usubst)

lemma RH_pre_RH_design:
  "$ok\<acute> \<sharp> P \<Longrightarrow> RH(pre\<^sub>R(RH(P \<turnstile> Q)) \<turnstile> R) = RH(P \<turnstile> R)"
  apply (simp add: rea_pre_RH_design RH_design_pre_neg_R1_R2c usubst)
  apply (subst subst_to_singleton)
  apply (simp add: unrest)
  apply (simp add: RH_design_subst_wait_pre)
  apply (simp add: usubst)
  apply (metis conj_pos_var_subst design_def vwb_lens_ok)
done

lemma RH_postcondition: "(RH(P \<turnstile> Q))\<^sup>t\<^sub>f = R1(R2s($ok \<and> P\<^sup>t\<^sub>f \<Rightarrow> Q\<^sup>t\<^sub>f))"
  by (simp add: RH_def R1_def R3c_def usubst R2s_def design_def)

lemma RH_postcondition_RH: "RH(P \<turnstile> (RH(P \<turnstile> Q))\<^sup>t\<^sub>f) = RH(P \<turnstile> Q)"
proof -
  have "RH(P \<turnstile> (RH(P \<turnstile> Q))\<^sup>t\<^sub>f) = RH (P \<turnstile> ($ok \<and> P\<^sup>t\<^sub>f \<Rightarrow> Q\<^sup>t\<^sub>f))"
    by (simp add: RH_postcondition RH_design_export_R1[THEN sym] RH_design_export_R2s[THEN sym])
  also have "... = RH (P \<turnstile> ($ok \<and> P\<^sup>t \<Rightarrow> Q\<^sup>t))"
    by (subst RH_design_subst_wait_post[THEN sym, of _ "($ok \<and> P\<^sup>t \<Rightarrow> Q\<^sup>t)"], simp add: usubst)
  also have "... = RH (P \<turnstile> (P\<^sup>t \<Rightarrow> Q\<^sup>t))"
    by (rel_auto)
  also have "... = RH (P \<turnstile> (P \<Rightarrow> Q))"
    by (subst design_subst_ok'[THEN sym, of _ "P \<Rightarrow> Q"], simp add: usubst)
  also have "... = RH (P \<turnstile> Q)"
    by (rel_auto)
  finally show ?thesis .
qed

lemma peri\<^sub>R_alt_def: "peri\<^sub>R(P) = (P\<^sup>t\<^sub>f)\<lbrakk>true/$ok\<rbrakk>\<lbrakk>true/$wait\<acute>\<rbrakk>"
  by (simp add: peri\<^sub>R_def usubst)

lemma post\<^sub>R_alt_def: "post\<^sub>R(P) = (P\<^sup>t\<^sub>f)\<lbrakk>true/$ok\<rbrakk>\<lbrakk>false/$wait\<acute>\<rbrakk>"
  by (simp add: post\<^sub>R_def usubst)

lemma design_export_ok_true: "P \<turnstile> Q\<lbrakk>true/$ok\<rbrakk> = P \<turnstile> Q"
  by (metis conj_pos_var_subst design_export_ok vwb_lens_ok)

lemma design_export_peri_ok_true: "P \<turnstile> Q\<lbrakk>true/$ok\<rbrakk> \<diamondop> R = P \<turnstile> Q \<diamondop> R"
  apply (subst design_export_ok_true[THEN sym])
  apply (simp add: usubst unrest)
  apply (metis design_export_ok_true out_in_indep out_var_uvar unrest_true unrest_usubst_id unrest_usubst_upd vwb_lens_mwb wait'_cond_subst wait_vwb_lens)
done

lemma design_export_post_ok_true: "P \<turnstile> Q \<diamondop> R\<lbrakk>true/$ok\<rbrakk> = P \<turnstile> Q \<diamondop> R"
  apply (subst design_export_ok_true[THEN sym])
  apply (simp add: usubst unrest)
  apply (metis design_export_ok_true out_in_indep out_var_uvar unrest_true unrest_usubst_id unrest_usubst_upd vwb_lens_mwb wait'_cond_subst wait_vwb_lens)
done

lemma RH_peri_RH_design:
  "RH(P \<turnstile> peri\<^sub>R(RH(P \<turnstile> Q \<diamondop> R)) \<diamondop> S) = RH(P \<turnstile> Q \<diamondop> S)"
  apply (simp add: peri\<^sub>R_alt_def subst_wait'_left_subst design_export_peri_ok_true RH_postcondition)
  apply (simp add: rea_peri_RH_design RH_design_peri_R1 RH_design_peri_R2s)
oops

lemma R1_R2s_tr_diff_conj: "(R1 (R2s ($tr\<acute> =\<^sub>u $tr \<and> P))) = ($tr\<acute> =\<^sub>u $tr \<and> R2s(P))"
  apply (rel_auto) using minus_zero_eq by blast

lemma R2s_state'_eq_state: "R2s ($\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R) = ($\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R)"
  by (simp add: R2s_def usubst)

lemma skip_r_rea: "II = ($ok\<acute> =\<^sub>u $ok \<and> $wait\<acute> =\<^sub>u $wait \<and> $tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R)"
  by (rel_auto)

lemma wait_pre_lemma:
  assumes "$wait\<acute> \<sharp> P"
  shows "(P \<and> \<not> $wait\<acute> ;; \<not> pre\<^sub>R Q) = (P ;; \<not> pre\<^sub>R Q)"
proof -
  have "(P \<and> \<not> $wait\<acute> ;; \<not> pre\<^sub>R Q) = (P \<and> $wait\<acute> =\<^sub>u false ;; \<not> pre\<^sub>R Q)"
    by (rel_auto)
  also have "... = (P\<lbrakk>false/$wait\<acute>\<rbrakk> ;; (\<not> pre\<^sub>R Q)\<lbrakk>false/$wait\<rbrakk>)"
    by (metis false_alt_def seqr_left_one_point wait_vwb_lens)
  also have "... = (P ;; \<not> pre\<^sub>R Q)"
    by (simp add: usubst unrest assms)
  finally show ?thesis .
qed

lemma rea_left_unit_lemma:
  assumes "$ok  \<sharp> P" "$wait \<sharp> P"
  shows "(($tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R) ;; P) = P"
proof -
  have "P = (II ;; P)"
    by simp
  also have "... = (($ok\<acute> =\<^sub>u $ok \<and> $wait\<acute> =\<^sub>u $wait \<and> $tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R) ;; P)"
    by (metis skip_r_rea)
  also from assms have "... = (($tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R) ;; P)"
    by (simp add: seqr_insert_ident_left assms unrest)
  finally show ?thesis ..
qed

lemma rea_right_unit_lemma:
  assumes "$ok\<acute>  \<sharp> P" "$wait\<acute> \<sharp> P"
  shows "(P ;; ($tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R)) = P"
proof -
  have "P = (P ;; II)"
    by simp
  also have "... = (P ;; ($ok\<acute> =\<^sub>u $ok \<and> $wait\<acute> =\<^sub>u $wait \<and> $tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R))"
    by (metis skip_r_rea)
  also from assms have "... = (P ;; ($tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R))"
    by (simp add: seqr_insert_ident_right assms unrest)
  finally show ?thesis ..
qed

lemma skip_rea_left_unit:
  assumes "P is CSP"
  shows "(II\<^sub>r ;; P) = P"
proof -
  have "(II\<^sub>r ;; P) = (II\<^sub>r ;; RH (pre\<^sub>R P \<turnstile> peri\<^sub>R P \<diamondop> post\<^sub>R P))"
    by (metis CSP_reactive_tri_design assms)
  also have "... = (RH(true \<turnstile> false \<diamondop> ($tr\<acute> =\<^sub>u $tr \<and>  $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R)) ;; RH (pre\<^sub>R P \<turnstile> peri\<^sub>R P \<diamondop> post\<^sub>R P))"
    by (metis skip_rea_reactive_tri_design')
  also have "... = RH (pre\<^sub>R P \<turnstile> peri\<^sub>R P \<diamondop> post\<^sub>R P)"
    apply (subst RH_tri_design_composition)
    apply (simp_all add: unrest R2s_true R1_false R1_neg_pre R1_peri R1_post R2s_pre R2s_peri R2s_post CSP_R1_R2s R1_R2s_tr_diff_conj assms)
    apply (simp add: R2s_conj R2s_state'_eq_state wait_pre_lemma rea_left_unit_lemma unrest)
  done
  also have "... = P"
    by (metis CSP_reactive_tri_design assms)
  finally show ?thesis .
qed

text {* This theorem tells us that processes consisting of a precondition and upward closed
  predicate over tr have R1(true) as a right unit. *}

lemma R1_true_right_unit_form:
  "out\<alpha> \<sharp> c \<Longrightarrow> (\<not> (c \<and> \<not> ($tr\<acute> \<ge>\<^sub>u $tr ^\<^sub>u \<guillemotleft>tt\<guillemotright>)) ;; R1(true)) = (\<not> (c \<and> \<not> ($tr\<acute> \<ge>\<^sub>u $tr ^\<^sub>u \<guillemotleft>tt\<guillemotright>)))"
  by (rel_auto, blast)

lemma skip_rea_left_semi_unit:
  assumes "P is CSP"
  shows "(P ;; II\<^sub>r) = RH ((\<not> (\<not> pre\<^sub>R P ;; R1 true)) \<turnstile> peri\<^sub>R P \<diamondop> post\<^sub>R P)"
proof -
  have "(P ;; II\<^sub>r) = (RH (pre\<^sub>R P \<turnstile> peri\<^sub>R P \<diamondop> post\<^sub>R P) ;; II\<^sub>r)"
    by (metis CSP_reactive_tri_design assms)
  also have "... = (RH (pre\<^sub>R P \<turnstile> peri\<^sub>R P \<diamondop> post\<^sub>R P) ;; RH(true \<turnstile> false \<diamondop> ($tr\<acute> =\<^sub>u $tr \<and> $\<Sigma>\<^sub>R\<acute> =\<^sub>u $\<Sigma>\<^sub>R)))"
    by (metis skip_rea_reactive_tri_design')
  also have "... = RH ((\<not> (\<not> pre\<^sub>R P ;; R1 true)) \<turnstile> peri\<^sub>R P \<diamondop> post\<^sub>R P)"
    apply (subst RH_tri_design_composition)
    apply (simp_all add: unrest R2s_true R1_false R2s_false R1_neg_pre R1_peri R1_post R2s_pre R2s_peri R2s_post CSP_R1_R2s R1_R2s_tr_diff_conj assms)
    apply (simp add: R2s_conj R2s_state'_eq_state wait_pre_lemma rea_right_unit_lemma unrest)
  done
  finally show ?thesis .
qed

lemma HR_design_wait_false: "RH(P \<^sub>f \<turnstile> Q \<^sub>f) = RH(P \<turnstile> Q)"
  by (metis R3c_subst_wait RH_R2c_def wait_false_design)

lemma RH_design_R1_neg_precond: "RH((\<not> R1(\<not> P)) \<turnstile> Q) = RH(P \<turnstile> Q)"
  by (rel_auto)

lemma RH_design_pre_neg_conj_R1: "RH((\<not> R1 P \<and> \<not> R1 Q) \<turnstile> R) = RH((\<not> P \<and> \<not> Q) \<turnstile> R)"
  by (rel_auto)

subsection {* Signature *}

definition [urel_defs]: "Miracle = RH(true \<turnstile> false \<diamondop> false)"

definition [urel_defs]: "Chaos = RH(false \<turnstile> true \<diamondop> true)"

definition [urel_defs]: "Term = RH(true \<turnstile> true \<diamondop> true)"

definition assigns_rea :: "'\<alpha> usubst \<Rightarrow> ('t::ordered_cancel_monoid_diff, '\<alpha>) hrelation_rp" ("\<langle>_\<rangle>\<^sub>R") where
"assigns_rea \<sigma> = RH(true \<turnstile> false \<diamondop> ($tr\<acute> =\<^sub>u $tr \<and> \<lceil>\<langle>\<sigma>\<rangle>\<^sub>a\<rceil>\<^sub>R))"

definition rea_design_sup :: "_ set \<Rightarrow> _" ("\<Sqinter>\<^sub>R") where
"\<Sqinter>\<^sub>R A = (if (A = {}) then Miracle else \<Sqinter> A)"

definition rea_design_inf :: "_ set \<Rightarrow> _" ("\<Squnion>\<^sub>R") where
"\<Squnion>\<^sub>R A = (if (A = {}) then Chaos else \<Squnion> A)"

definition rea_design_par :: "_ \<Rightarrow> _ \<Rightarrow> _" (infixr "\<parallel>\<^sub>R" 85) where
"P \<parallel>\<^sub>R Q = RH((pre\<^sub>R(P)  \<and> pre\<^sub>R(Q)) \<turnstile> (P\<^sup>t\<^sub>f \<and> Q\<^sup>t\<^sub>f))"

lemma Miracle_greatest:
  assumes "P is CSP"
  shows "P \<sqsubseteq> Miracle"
proof -
  have "P = RH (pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P))"
    by (metis CSP_reactive_tri_design assms)
  also have "... \<sqsubseteq> RH(true \<turnstile> false)"
    by (rule RH_monotone, rel_auto)
  also have "RH(true \<turnstile> false) = RH(true \<turnstile> false \<diamondop> false)"
    by (simp add: wait'_cond_def cond_def)
  finally show ?thesis
    by (simp add: Miracle_def)
qed
   
lemma Chaos_least:
  assumes "P is CSP"
  shows "Chaos \<sqsubseteq> P"
proof -
  have "Chaos = RH(true)"
    by (simp add: Chaos_def design_def)   
  also have "... \<sqsubseteq> RH(pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P))"
    by (simp add: RH_monotone)
  also have "RH(pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P)) = P"
    by (metis CSP_reactive_tri_design assms)
  finally show ?thesis .
qed

lemma Miracle_left_zero:
  assumes "P is CSP"
  shows "(Miracle ;; P) = Miracle"
proof -
  have "(Miracle ;; P) = (RH(true \<turnstile> false \<diamondop> false) ;; RH (pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P)))"
    by (metis CSP_reactive_tri_design Miracle_def assms)
  also have "... = RH(true \<turnstile> false \<diamondop> false)"
    by (simp add: RH_tri_design_composition R1_false R2s_true R2s_false R2c_true R1_true_comp unrest usubst)
  also have "... = Miracle"
    by (simp add: Miracle_def)
  finally show ?thesis .
qed

lemma Chaos_def': "Chaos = RH(false \<turnstile> true)"
  by (simp add: Chaos_def design_false_pre)

lemma Miracle_CSP_false: "Miracle = CSP(false)"
  by (rel_auto)

lemma Chaos_CSP_true: "Chaos = CSP(true)"
  by (rel_auto)

lemma Chaos_left_zero:
  assumes "P is CSP"
  shows "(Chaos ;; P) = Chaos"
proof -
  have "(Chaos ;; P) = (RH(false \<turnstile> true \<diamondop> true) ;; RH (pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P)))"
    by (metis CSP_reactive_tri_design Chaos_def assms)
  also have "... = RH ((\<not> R1 true \<and> \<not> (R1 true \<and> \<not> $wait\<acute> ;; R1 (\<not> R2c (pre\<^sub>R P)))) \<turnstile>
                       (true \<or> (R1 true ;; R1 (R2c (peri\<^sub>R P)))) \<diamondop> (R1 true ;; R1 (R2c (post\<^sub>R P))))"
    by (simp add: RH_tri_design_composition R2s_true R1_true_comp R2s_false unrest, metis (no_types) R1_R2s_R2c R1_negate_R1) 
  also have "... = RH ((\<not> $ok \<or> R1 true \<or> (R1 true \<and> \<not> $wait\<acute> ;; R1 (\<not> R2c (pre\<^sub>R P)))) \<or>
                       $ok\<acute> \<and> (true \<or> (R1 true ;; R1 (R2c (peri\<^sub>R P)))) \<diamondop> (R1 true ;; R1 (R2c (post\<^sub>R P))))"
    by (simp add: design_def impl_alt_def)
  also have "... = RH(R1((\<not> $ok \<or> R1 true \<or> (R1 true \<and> \<not> $wait\<acute> ;; R1 (\<not> R2c (pre\<^sub>R P)))) \<or>
                      $ok\<acute> \<and> (true \<or> (R1 true ;; R1 (R2c (peri\<^sub>R P)))) \<diamondop> (R1 true ;; R1 (R2c (post\<^sub>R P)))))"
    by (simp add: R1_R2c_commute R1_R3c_commute R1_idem RH_R2c_def)
  also have "... = RH(R1((\<not> $ok \<or> true \<or> (R1 true \<and> \<not> $wait\<acute> ;; R1 (\<not> R2c (pre\<^sub>R P)))) \<or>
                      $ok\<acute> \<and> (true \<or> (R1 true ;; R1 (R2c (peri\<^sub>R P)))) \<diamondop> (R1 true ;; R1 (R2c (post\<^sub>R P)))))"
    by (metis (no_types, hide_lams) R1_disj R1_idem)
  also have "... = RH(true)"
    by (simp add: R1_R2c_commute R1_R3c_commute R1_idem RH_R2c_def)
  also have "... = Chaos"
    by (simp add: Chaos_def design_def)
  finally show ?thesis .
qed

lemma RH_design_choice:
  "(RH(P \<turnstile> Q\<^sub>1 \<diamondop> Q\<^sub>2) \<sqinter> RH(R \<turnstile> S\<^sub>1 \<diamondop> S\<^sub>2)) = RH((P \<and> R) \<turnstile> ((Q\<^sub>1 \<or> S\<^sub>1) \<diamondop> (Q\<^sub>2 \<or> S\<^sub>2)))"
proof -
  have "(RH(P \<turnstile> Q\<^sub>1 \<diamondop> Q\<^sub>2) \<sqinter> RH(R \<turnstile> S\<^sub>1 \<diamondop> S\<^sub>2)) = RH((P \<turnstile> Q\<^sub>1 \<diamondop> Q\<^sub>2) \<sqinter> (R \<turnstile> S\<^sub>1 \<diamondop> S\<^sub>2))"
    by (simp add: disj_upred_def[THEN sym] RH_disj[THEN sym])
  also have "... = RH ((P \<and> R) \<turnstile> (Q\<^sub>1 \<diamondop> Q\<^sub>2 \<or> S\<^sub>1 \<diamondop> S\<^sub>2))"
    by (simp add: design_choice)
  also have "... = RH ((P \<and> R) \<turnstile> ((Q\<^sub>1 \<or> S\<^sub>1) \<diamondop> (Q\<^sub>2 \<or> S\<^sub>2)))"
  proof -
    have "(Q\<^sub>1 \<diamondop> Q\<^sub>2 \<or> S\<^sub>1 \<diamondop> S\<^sub>2) = ((Q\<^sub>1 \<or> S\<^sub>1) \<diamondop> (Q\<^sub>2 \<or> S\<^sub>2))"
      by (rel_auto)
    thus ?thesis by simp
  qed
  finally show ?thesis .
qed

lemma USUP_CSP_closed:
  assumes "A \<noteq> {}" "\<forall> P \<in> A. P is CSP"
  shows "(\<Sqinter> A) is CSP"
proof -
  from assms have A: "A = CSP ` A"
    by (auto simp add: Healthy_def rev_image_eqI)
  also have "(\<Sqinter> ...) = (\<Sqinter> P \<in> A. CSP(P))"
    by auto
  also have "... = (\<Sqinter> P \<in> A \<bullet> CSP(P))"
    by (simp add: USUP_as_Sup_collect)
  also have "... = (\<Sqinter> P \<in> A \<bullet> RH((\<not> P\<^sup>f\<^sub>f) \<turnstile> P\<^sup>t\<^sub>f))"
    by (metis (no_types) CSP_RH_design_form)
  also have "... = RH(\<Sqinter> P \<in> A \<bullet> (\<not> P\<^sup>f\<^sub>f) \<turnstile> P\<^sup>t\<^sub>f)"
    by (simp add: RH_USUP assms(1))
  also have "... = RH((\<Squnion> P \<in> A \<bullet> \<not> P\<^sup>f\<^sub>f) \<turnstile> (\<Sqinter> P \<in> A \<bullet> P\<^sup>t\<^sub>f))"
    by (simp add: design_USUP assms)
  also have "... = CSP(...)"
    by (simp add: CSP_RH_design unrest)
  finally show ?thesis
    by (simp add: Healthy_def CSP_idem)
qed

lemma UINF_CSP_closed:
  assumes "A \<noteq> {}" "\<forall> P \<in> A. P is CSP"
  shows "(\<Squnion> A) is CSP"
proof -
  from assms have A: "A = CSP ` A"
    by (auto simp add: Healthy_def rev_image_eqI)
  also have "(\<Squnion> ...) = (\<Squnion> P \<in> A. CSP(P))"
    by auto
  also have "... = (\<Squnion> P \<in> A \<bullet> CSP(P))"
    by (simp add: UINF_as_Inf_collect)
  also have "... = (\<Squnion> P \<in> A \<bullet> RH((\<not> P\<^sup>f\<^sub>f) \<turnstile> P\<^sup>t\<^sub>f))"
    by (simp add: CSP_RH_design_form)
  also have "... = RH(\<Squnion> P \<in> A \<bullet> (\<not> P\<^sup>f\<^sub>f) \<turnstile> P\<^sup>t\<^sub>f)"
    by (simp add: RH_UINF assms(1))
  also have "... = RH ((\<Sqinter> P \<in> A \<bullet> \<not> P\<^sup>f\<^sub>f) \<turnstile> (\<Squnion> P \<in> A \<bullet> \<not> P\<^sup>f\<^sub>f \<Rightarrow> P\<^sup>t\<^sub>f))"
    by (simp add: design_UINF)
  also have "... = CSP(...)"
    by (simp add: CSP_RH_design unrest)
  finally show ?thesis
    by (simp add: Healthy_def CSP_idem)
qed

lemma CSP_sup_closed:
  assumes "\<forall> P \<in> A. P is CSP"
  shows "(\<Sqinter>\<^sub>R A) is CSP"
proof (cases "A = {}")
  case True
  moreover have "Miracle is CSP"
    by (simp add: Miracle_def Healthy_def CSP_RH_design unrest)
  ultimately show ?thesis
    by (simp add: rea_design_sup_def)
next
  case False
  with USUP_CSP_closed assms show ?thesis
    by (auto simp add: rea_design_sup_def)
qed

lemma CSP_sup_below:
  assumes "\<forall> Q \<in> A. Q is CSP" "P \<in> A"
  shows "\<Sqinter>\<^sub>R A \<sqsubseteq> P"
  using assms
  by (auto simp add: rea_design_sup_def Sup_upper)

lemma CSP_sup_upper_bound:
  assumes "\<forall> Q \<in> A. Q is CSP" "\<forall> Q \<in> A. P \<sqsubseteq> Q" "P is CSP"
  shows "P \<sqsubseteq> \<Sqinter>\<^sub>R A"
proof (cases "A = {}")
  case True
  thus ?thesis
    by (simp add: rea_design_sup_def Miracle_greatest assms)
next
  case False
  thus ?thesis
    by (simp add: rea_design_sup_def cSup_least assms)
qed

lemma CSP_inf_closed:
  assumes "\<forall> P \<in> A. P is CSP"
  shows "(\<Squnion>\<^sub>R A) is CSP"
proof (cases "A = {}")
  case True
  moreover have "Chaos is CSP"
    by (simp add: Chaos_def Healthy_def CSP_RH_design unrest)
  ultimately show ?thesis
    by (simp add: rea_design_inf_def)
next
  case False
  with UINF_CSP_closed assms show ?thesis
    by (auto simp add: rea_design_inf_def)
qed

lemma CSP_inf_above:
  assumes "\<forall> Q \<in> A. Q is CSP" "P \<in> A"
  shows "P \<sqsubseteq> \<Squnion>\<^sub>R A"
  using assms
  by (auto simp add: rea_design_inf_def Inf_lower)

lemma CSP_inf_lower_bound:
  assumes "\<forall> P \<in> A. P is CSP" "\<forall> P \<in> A. P \<sqsubseteq> Q" "Q is CSP"
  shows "\<Squnion>\<^sub>R A \<sqsubseteq> Q"
proof (cases "A = {}")
  case True
  thus ?thesis
    by (simp add: rea_design_inf_def Chaos_least assms)
next
  case False
  thus ?thesis
    by (simp add: rea_design_inf_def cInf_greatest assms)
qed

lemma assigns_lift_rea_unfold:
  "($wait\<acute> =\<^sub>u $wait \<and> $tr\<acute> =\<^sub>u $tr \<and> \<lceil>\<langle>\<sigma>\<rangle>\<^sub>a\<rceil>\<^sub>R) = \<lceil>\<langle>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>r\<rangle>\<^sub>a\<rceil>\<^sub>D"
  by (rel_auto)

lemma assigns_lift_des_unfold:
  "($ok\<acute> =\<^sub>u $ok \<and> \<lceil>\<langle>\<sigma>\<rangle>\<^sub>a\<rceil>\<^sub>D) = \<langle>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>D\<rangle>\<^sub>a"
  by (rel_auto)

lemma assigns_rea_comp_lemma: 
  assumes "$ok \<sharp> P" "$wait \<sharp> P"
  shows "(($tr\<acute> =\<^sub>u $tr \<and> \<lceil>\<langle>\<sigma>\<rangle>\<^sub>a\<rceil>\<^sub>R) ;; P) = (\<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> P)"
proof -
  have "(($tr\<acute> =\<^sub>u $tr \<and> \<lceil>\<langle>\<sigma>\<rangle>\<^sub>a\<rceil>\<^sub>R) ;; P) = 
        (($ok\<acute> =\<^sub>u $ok \<and> $wait\<acute> =\<^sub>u $wait \<and> $tr\<acute> =\<^sub>u $tr \<and> \<lceil>\<langle>\<sigma>\<rangle>\<^sub>a\<rceil>\<^sub>R) ;; P)"
    by (simp add: seqr_insert_ident_left unrest assms)
  also have "... = (\<langle>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rangle>\<^sub>a ;; P)"
    by (simp add: assigns_lift_rea_unfold assigns_lift_des_unfold, rel_auto)
  also have "... = (\<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> P)"
    by (simp add: assigns_r_comp)
  finally show ?thesis .
qed

lemma R1_R2s_frame:
  "R1 (R2s ($tr\<acute> =\<^sub>u $tr \<and> \<lceil>P\<rceil>\<^sub>R)) = ($tr\<acute> =\<^sub>u $tr \<and> \<lceil>P\<rceil>\<^sub>R)"
    apply (rel_auto) 
    using minus_zero_eq apply blast
done

lemma assigns_rea_comp:
  assumes "$ok \<sharp> P" "$ok \<sharp> Q\<^sub>1" "$ok \<sharp> Q\<^sub>2" "$wait \<sharp> P" "$wait \<sharp> Q\<^sub>1" "$wait \<sharp> Q\<^sub>2"
          "Q\<^sub>1 is R1" "Q\<^sub>2 is R1" "P is R2s" "Q\<^sub>1 is R2s" "Q\<^sub>2 is R2s"
  shows "(\<langle>\<sigma>\<rangle>\<^sub>R ;; RH(P \<turnstile> Q\<^sub>1 \<diamondop> Q\<^sub>2)) = RH(\<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> P \<turnstile> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>1 \<diamondop> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>2)"
proof -
  have "(\<langle>\<sigma>\<rangle>\<^sub>R ;; RH(P \<turnstile> Q\<^sub>1 \<diamondop> Q\<^sub>2)) = 
        (RH (true \<turnstile> false \<diamondop> ($tr\<acute> =\<^sub>u $tr \<and> \<lceil>\<langle>\<sigma>\<rangle>\<^sub>a\<rceil>\<^sub>R)) ;; RH (P \<turnstile> Q\<^sub>1 \<diamondop> Q\<^sub>2))"
    by (simp add: assigns_rea_def)
  also have "... = RH ((\<not> (($tr\<acute> =\<^sub>u $tr \<and> \<lceil>\<langle>\<sigma>\<rangle>\<^sub>a\<rceil>\<^sub>R) \<and> \<not> $wait\<acute> ;; 
                       R1 (\<not> P))) \<turnstile> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>1 \<diamondop> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>2)"
    by (simp add: RH_tri_design_composition unrest assms R2s_true R1_false R1_R2s_frame Healthy_if assigns_rea_comp_lemma)
  also have "... = RH ((\<not> (($tr\<acute> =\<^sub>u $tr \<and> \<lceil>\<langle>\<sigma>\<rangle>\<^sub>a\<rceil>\<^sub>R) \<and> $wait\<acute> =\<^sub>u \<guillemotleft>False\<guillemotright> ;; 
                       R1 (\<not> P))) \<turnstile> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>1 \<diamondop> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>2)"
    by (simp add: false_alt_def[THEN sym])
  also have "... = RH ((\<not> (($tr\<acute> =\<^sub>u $tr \<and> \<lceil>\<langle>\<sigma>\<rangle>\<^sub>a\<rceil>\<^sub>R)\<lbrakk>false/$wait\<acute>\<rbrakk> ;; 
                       (R1 (\<not> P))\<lbrakk>false/$wait\<rbrakk>)) \<turnstile> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>1 \<diamondop> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>2)"
    by (simp add: seqr_left_one_point false_alt_def)
  also have "... = RH ((\<not> (($tr\<acute> =\<^sub>u $tr \<and> \<lceil>\<langle>\<sigma>\<rangle>\<^sub>a\<rceil>\<^sub>R) ;; (R1 (\<not> P)))) \<turnstile> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>1 \<diamondop> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>2)"
    by (simp add: R1_def usubst unrest assms)
  also have "... = RH ((\<not> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> R1 (\<not> P)) \<turnstile> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>1 \<diamondop> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>2)"
    by (simp add: assigns_rea_comp_lemma assms unrest)
  also have "... = RH ((\<not> R1 (\<not> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> P)) \<turnstile> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>1 \<diamondop> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>2)"
    by (simp add: R1_def usubst unrest)
  also have "... = RH ((\<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> P) \<turnstile> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>1 \<diamondop> \<lceil>\<sigma> \<oplus>\<^sub>s \<Sigma>\<^sub>R\<rceil>\<^sub>s \<dagger> Q\<^sub>2)"
    by (simp add: RH_design_R1_neg_precond)
  finally show ?thesis .
qed

lemma RH_design_par:
  assumes 
    "$ok\<acute> \<sharp> P\<^sub>1" "$wait \<sharp> P\<^sub>1" "$ok\<acute> \<sharp> P\<^sub>2" "$wait \<sharp> P\<^sub>2"
    "$ok\<acute> \<sharp> Q\<^sub>1" "$wait \<sharp> Q\<^sub>1" "$ok\<acute> \<sharp> Q\<^sub>2" "$wait \<sharp> Q\<^sub>2"
  shows "RH(P\<^sub>1 \<turnstile> Q\<^sub>1) \<parallel>\<^sub>R RH(P\<^sub>2 \<turnstile> Q\<^sub>2) = RH((P\<^sub>1 \<and> P\<^sub>2) \<turnstile> (Q\<^sub>1 \<and> Q\<^sub>2))"
proof -
  have "RH(P\<^sub>1 \<turnstile> Q\<^sub>1) \<parallel>\<^sub>R RH(P\<^sub>2 \<turnstile> Q\<^sub>2) = 
        RH ((\<not> R1 (R2c (\<not> P\<^sub>1\<lbrakk>true/$ok\<rbrakk>)) \<and> \<not> R1 (R2c (\<not> P\<^sub>2\<lbrakk>true/$ok\<rbrakk>))) \<turnstile>
            (R1 (R2s ($ok \<and> P\<^sub>1 \<Rightarrow> Q\<^sub>1)) \<and> R1 (R2s ($ok \<and> P\<^sub>2 \<Rightarrow> Q\<^sub>2))))"
    by (simp add: rea_design_par_def rea_pre_RH_design RH_postcondition, simp add: usubst assms)
  also have "... = 
        RH ((P\<^sub>1\<lbrakk>true/$ok\<rbrakk> \<and> P\<^sub>2\<lbrakk>true/$ok\<rbrakk>) \<turnstile>
            (R1 (R2s ($ok \<and> P\<^sub>1 \<Rightarrow> Q\<^sub>1)) \<and> R1 (R2s ($ok \<and> P\<^sub>2 \<Rightarrow> Q\<^sub>2))))"
    by (metis (no_types, hide_lams) R2c_and R2c_not RH_design_pre_R2c RH_design_pre_neg_conj_R1 double_negation)
  also have "... = RH ((P\<^sub>1 \<and> P\<^sub>2) \<turnstile> (R1 (R2s ($ok \<and> P\<^sub>1 \<Rightarrow> Q\<^sub>1)) \<and> R1 (R2s ($ok \<and> P\<^sub>2 \<Rightarrow> Q\<^sub>2))))"
    by (metis conj_pos_var_subst design_def subst_conj vwb_lens_ok)
  also have "... = RH ((P\<^sub>1 \<and> P\<^sub>2) \<turnstile> (R1 (R2s (($ok \<and> P\<^sub>1 \<Rightarrow> Q\<^sub>1) \<and> ($ok \<and> P\<^sub>2 \<Rightarrow> Q\<^sub>2)))))"
    by (simp add: R1_conj R2s_conj)
  also have "... = RH ((P\<^sub>1 \<and> P\<^sub>2) \<turnstile> (($ok \<and> P\<^sub>1 \<Rightarrow> Q\<^sub>1) \<and> ($ok \<and> P\<^sub>2 \<Rightarrow> Q\<^sub>2)))"
        by (metis (mono_tags, lifting) RH_design_export_R1 RH_design_export_R2s)
  also have "... = RH ((P\<^sub>1 \<and> P\<^sub>2) \<turnstile> (Q\<^sub>1 \<and> Q\<^sub>2))"
    by (rel_auto)
  finally show ?thesis .
qed 

lemma RH_tri_design_par:
  assumes 
    "$ok\<acute> \<sharp> P\<^sub>1" "$wait \<sharp> P\<^sub>1" "$ok\<acute> \<sharp> P\<^sub>2" "$wait \<sharp> P\<^sub>2"
    "$ok\<acute> \<sharp> Q\<^sub>1" "$wait \<sharp> Q\<^sub>1" "$ok\<acute> \<sharp> Q\<^sub>2" "$wait \<sharp> Q\<^sub>2"
    "$ok\<acute> \<sharp> R\<^sub>1" "$wait \<sharp> R\<^sub>1" "$ok\<acute> \<sharp> R\<^sub>2" "$wait \<sharp> R\<^sub>2"
  shows "RH(P\<^sub>1 \<turnstile> Q\<^sub>1 \<diamondop> R\<^sub>1) \<parallel>\<^sub>R RH(P\<^sub>2 \<turnstile> Q\<^sub>2 \<diamondop> R\<^sub>2) = RH((P\<^sub>1 \<and> P\<^sub>2) \<turnstile> (Q\<^sub>1 \<and> Q\<^sub>2) \<diamondop> (R\<^sub>1 \<and> R\<^sub>2))"
  by (simp add: RH_design_par assms unrest wait'_cond_conj_exchange)

lemma RH_design_par_comm:
  "P \<parallel>\<^sub>R Q = Q \<parallel>\<^sub>R P"
  by (simp add: rea_design_par_def utp_pred.inf_commute)

lemma RH_design_par_zero:
  assumes "P is CSP"
  shows "Chaos \<parallel>\<^sub>R P = Chaos"
proof -
  have "Chaos \<parallel>\<^sub>R P = RH (false \<turnstile> true \<diamondop> true) \<parallel>\<^sub>R RH (pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P))"
    by (simp add: Chaos_def CSP_reactive_tri_design assms)
  also have "... = RH (false \<turnstile> peri\<^sub>R P \<diamondop> post\<^sub>R P)"
    by (simp add: RH_tri_design_par unrest)
  also have "... = Chaos"
    by (simp add: Chaos_def design_false_pre)
  finally show ?thesis .
qed

lemma RH_design_par_unit:
  assumes "P is CSP"
  shows "Term \<parallel>\<^sub>R P = P"
proof -
  have "Term \<parallel>\<^sub>R P = RH (true \<turnstile> true \<diamondop> true) \<parallel>\<^sub>R RH (pre\<^sub>R(P) \<turnstile> peri\<^sub>R(P) \<diamondop> post\<^sub>R(P))"
    by (simp add: Term_def CSP_reactive_tri_design assms)
  also have "... = RH (pre\<^sub>R P \<turnstile> peri\<^sub>R P \<diamondop> post\<^sub>R P)"
    by (simp add: RH_tri_design_par unrest)
  also have "... = P"
    by (simp add: CSP_reactive_tri_design assms)
  finally show ?thesis .
qed

subsection {* Complete lattice *}

typedecl RDES
typedecl R1DES

abbreviation "R1DES \<equiv> UTHY(R1DES, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp)"

overloading
  r1des_hcond   == "utp_hcond :: (R1DES, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp) uthy \<Rightarrow> (('t,'\<alpha>) alphabet_rp \<times> ('t,'\<alpha>) alphabet_rp) Healthiness_condition"
begin
  definition r1des_hcond :: "(R1DES, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp) uthy \<Rightarrow> (('t,'\<alpha>) alphabet_rp \<times> ('t,'\<alpha>) alphabet_rp) Healthiness_condition" where
  [upred_defs]: "r1des_hcond T = R1 \<circ> \<^bold>H"
end

interpretation r1des_theory: utp_theory "UTHY(R1DES, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp)"
  by (unfold_locales, simp_all add: r1des_hcond_def, metis CSP1_R1_H1 H1_H2_idempotent H2_R1_comm R1_idem)

abbreviation "RDES \<equiv> UTHY(RDES, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp)"

overloading
  rdes_hcond   == "utp_hcond :: (RDES, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp) uthy \<Rightarrow> (('t,'\<alpha>) alphabet_rp \<times> ('t,'\<alpha>) alphabet_rp) Healthiness_condition"
begin
  definition rdes_hcond :: "(RDES, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp) uthy \<Rightarrow> (('t,'\<alpha>) alphabet_rp \<times> ('t,'\<alpha>) alphabet_rp) Healthiness_condition" where
  [upred_defs]: "rdes_hcond T = CSP"
end

interpretation rdes_theory: utp_theory "UTHY(RDES, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp)"
  by (unfold_locales, simp_all add: rdes_hcond_def CSP_idem)

lemma Miracle_is_top: "\<^bold>\<top>\<^bsub>RDES\<^esub> = Miracle"
  apply (auto intro!:some_equality simp add: atop_def some_equality greatest_def utp_order_def rdes_hcond_def)
  apply (metis CSP_sup_closed emptyE rea_design_sup_def)
  using Miracle_greatest apply blast
  apply (metis CSP_sup_closed dual_order.antisym equals0D rea_design_sup_def Miracle_greatest)
done

lemma Chaos_is_bot: "\<^bold>\<bottom>\<^bsub>RDES\<^esub> = Chaos"
  apply (auto intro!:some_equality simp add: abottom_def some_equality least_def utp_order_def rdes_hcond_def)
  apply (metis CSP_inf_closed emptyE rea_design_inf_def)
  using Chaos_least apply blast
  apply (metis Chaos_least CSP_inf_closed dual_order.antisym equals0D rea_design_inf_def)
done

interpretation hrd_lattice: utp_theory_lattice "UTHY(RDES, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp)"
  rewrites "carrier (uthy_order RDES) = \<lbrakk>CSP\<rbrakk>\<^sub>H"
  and "\<top>\<^bsub>uthy_order RDES\<^esub> = Miracle"
  and "\<bottom>\<^bsub>uthy_order RDES\<^esub> = Chaos"
  apply (unfold_locales)
  apply (simp_all add: Miracle_is_top Chaos_is_bot)
  apply (simp_all add: utp_order_def rdes_hcond_def)
  apply (rename_tac A)
  apply (rule_tac x="\<Squnion>\<^sub>R A" in exI, auto intro:CSP_inf_above CSP_inf_lower_bound CSP_inf_closed simp add: least_def Upper_def CSP_inf_above)
  apply (rename_tac A)
  apply (rule_tac x="\<Sqinter>\<^sub>R A" in exI, auto intro:CSP_sup_below CSP_sup_upper_bound CSP_sup_closed simp add: greatest_def Lower_def CSP_inf_above)
done

abbreviation rdes_lfp :: "_ \<Rightarrow> _" ("\<mu>\<^sub>R") where
"\<mu>\<^sub>R F \<equiv> \<mu>\<^bsub>uthy_order RDES\<^esub> F"

abbreviation rdes_gfp :: "_ \<Rightarrow> _" ("\<nu>\<^sub>R") where
"\<nu>\<^sub>R F \<equiv> \<nu>\<^bsub>uthy_order RDES\<^esub> F"

lemma rdes_lfp_copy: "\<lbrakk> mono F; F \<in> \<lbrakk>CSP\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>CSP\<rbrakk>\<^sub>H \<rbrakk> \<Longrightarrow> \<mu>\<^sub>R F = F (\<mu>\<^sub>R F)"
  by (metis hrd_lattice.LFP_unfold mono_Monotone_utp_order)

lemma rdes_gfp_copy: "\<lbrakk> mono F; F \<in> \<lbrakk>CSP\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>CSP\<rbrakk>\<^sub>H \<rbrakk> \<Longrightarrow> \<nu>\<^sub>R F = F (\<nu>\<^sub>R F)"
  by (metis hrd_lattice.GFP_unfold mono_Monotone_utp_order)

lemma RH_H1_H2_eq_CSP: "\<^bold>R (\<^bold>H P) = CSP P"
  by (metis (no_types, lifting) CSP1_R1_H1 CSP1_R2c_commute CSP1_R3c_commute CSP2_def R1_H2_commute R1_R2c_commute R1_R2c_is_R2 R2_R3c_commute R2c_H2_commute R3c_H2_commute RH_alt_def'')

lemma Des_Rea_galois_lemma_1: "R1(\<^bold>H(R1(P))) \<sqsubseteq> R1(P)"
  by (rel_auto)

lemma "\<^bold>R(CSP(P)) = CSP(P)"
  by (rel_auto)

lemma "galois_connection (R2a' \<Leftarrow>\<langle>R2a',id\<rangle>\<Rightarrow> id)"
proof (simp add: mk_conn_def, rule galois_connectionI', simp_all add: utp_partial_order)
  show "id \<in> \<lbrakk>R2a'\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>id\<rbrakk>\<^sub>H"
    using Healthy_Idempotent Idempotent_id by blast
  show "R2a' \<in> \<lbrakk>id\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>R2a'\<rbrakk>\<^sub>H"
    by (simp add: Healthy_def R2a'_idem)
  show "isotone (utp_order R2a') (utp_order id) id"
    by (simp add: isotone_utp_orderI)
  show "isotone (utp_order id) (utp_order R2a') R2a'"
  by (simp add: Monotonic_def R2a'_mono isotone_utp_orderI)
  show "\<And> X. X is id \<Longrightarrow> R2a' X \<sqsubseteq> X"
    using R2a'_weakening by blast
  show "\<And> X. X is R2a' \<Longrightarrow> X \<sqsubseteq> R2a' X"
    by (simp add: Healthy_def)
qed
    
lemma Des_Rea_galois_lemma_2: "CSP(P) \<sqsubseteq> \<^bold>H(\<^bold>R(CSP(P)))"
  apply (rel_auto)
oops  

lemma R2c_H1_H2_commute: "R2c(\<^bold>H(P)) = \<^bold>H(R2c(P))"
  by (rel_auto)

lemma funcset_into_Idempotent: "Idempotent H \<Longrightarrow> H \<in> X \<rightarrow> \<lbrakk>H\<rbrakk>\<^sub>H"
  by (simp add: Healthy_def' Idempotent_def)

interpretation galois_connection "R1DES \<leftarrow>\<langle>id,R2c \<circ> R3c\<rangle>\<rightarrow> RDES"
proof (simp add: mk_conn_def, rule galois_connectionI', simp_all add: utp_partial_order r1des_hcond_def rdes_hcond_def)
  show "R2c \<circ> R3c \<in> \<lbrakk>R1 \<circ> \<^bold>H\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>CSP\<rbrakk>\<^sub>H"
    by (simp add: Pi_iff Healthy_def', metis R1_R2c_commute R1_R3c_commute R3c_idem RH_H1_H2_eq_CSP RH_absorbs_R2c RH_alt_def'')
  show "id \<in> \<lbrakk>CSP\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>R1 \<circ> \<^bold>H\<rbrakk>\<^sub>H"
    by (simp add: Pi_iff Healthy_def', metis CSP1_via_H1 CSP2_def RH_H1_H2_eq_CSP RH_alt_def RH_alt_def' RH_idem)
  show "isotone (utp_order (R1 \<circ> \<^bold>H)) (utp_order CSP) (R2c \<circ> R3c)"
    by (auto intro: isotone_utp_orderI Monotonic_comp R2c_Monotonic R3c_Monotonic)
  show "isotone (utp_order CSP) (utp_order (R1 \<circ> \<^bold>H)) id"
    by (auto intro: isotone_utp_orderI Monotonic_comp Monotonic_id)
  show "\<And> P. P is CSP \<Longrightarrow> R2c (R3c P) \<sqsubseteq> P"
    by (metis (no_types, lifting) CSP_R1_R2s CSP_healths(3) Healthy_def' R1_R2c_commute R2c_R2s_absorb eq_refl)
  show "\<And> P. P is R1 \<circ> \<^bold>H \<Longrightarrow> P \<sqsubseteq> R2c (R3c P)"
oops

interpretation Des_Rea_galois: galois_connection "DES \<leftarrow>\<langle>\<^bold>H,\<^bold>R\<rangle>\<rightarrow> RDES"
proof (simp add: mk_conn_def, rule galois_connectionI', simp_all add: utp_partial_order rdes_hcond_def des_hcond_def)
  show "\<^bold>R \<in> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>CSP\<rbrakk>\<^sub>H"
    by (metis (no_types, lifting) CSP_idem Healthy_def' Pi_I' RH_H1_H2_eq_CSP mem_Collect_eq)
  show "\<^bold>H \<in> \<lbrakk>CSP\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>H\<rbrakk>\<^sub>H"
    by (rule funcset_into_Idempotent, rule H1_H2_Idempotent)
  show "isotone (utp_order \<^bold>H) (utp_order CSP) \<^bold>R"
    by (rule isotone_utp_orderI, metis rea_hcond_def rea_utp_theory_mono.HCond_Mono)
  show "isotone (utp_order CSP) (utp_order \<^bold>H) \<^bold>H"
    by (rule isotone_utp_orderI, simp add: H1_H2_monotonic)
  show "\<And> X. X is CSP \<Longrightarrow> \<^bold>R (\<^bold>H X) \<sqsubseteq> X"
    by (simp add: CSP_RH_design_form CSP_reactive_design RH_H1_H2_eq_CSP)
  show "\<And> X. X is \<^bold>H \<Longrightarrow> X \<sqsubseteq> \<^bold>H (\<^bold>R X)"
  proof -
    fix P :: "('t::ordered_cancel_monoid_diff,'\<alpha>) hrelation_rp"
    assume "P is \<^bold>H"
    hence "(P \<sqsubseteq> \<^bold>H (\<^bold>R P)) \<longleftrightarrow> (\<^bold>H(P) \<sqsubseteq> \<^bold>H(\<^bold>R(\<^bold>H(P))))"
      by (simp add: Healthy_def')
    also have "... \<longleftrightarrow> (\<^bold>H(P) \<sqsubseteq> \<^bold>H(R1(\<^bold>H(P))))"
      oops

subsection {* Reactive design parallel-by-merge *}

definition [upred_defs]: "nil\<^sub>r\<^sub>m = (nil\<^sub>m \<triangleleft> $0-ok \<and> $1-ok \<triangleright> $tr\<^sub>< \<le>\<^sub>u $tr\<acute>)"

text {* @{term "nil\<^sub>r\<^sub>m"} is the parallel system which does nothing if the parallel predicates have both 
  terminated ($0.ok \wedge 1.ok$), and otherwise guarantees only the merged trace gets longer. *}

definition [upred_defs]: "div\<^sub>m = ($tr \<le>\<^sub>u $0-tr\<acute> \<and> $tr \<le>\<^sub>u $1-tr\<acute> \<and> $\<Sigma>\<^sub><\<acute> =\<^sub>u $\<Sigma>)"

text {* @{term "div\<^sub>m"} is the parallel system where both sides traces get longer than the initial
  trace and identifies the before values of the variables. *}

definition [upred_defs]: "wait\<^sub>m = skip\<^sub>m\<lbrakk>true,true/$ok,$wait\<rbrakk>"

text {* @{term "wait\<^sub>m"} is the parallel system where ok and wait are both true and all other variables
  are identified .*}


text {* R3c implicitly depends on CSP1, and therefore it requires that both sides be CSP1. We also
  require that both sides are R3c, and that @{term "wait\<^sub>m"} is a quasi-unit, and @{term "div\<^sub>m"} yields
  divergence. *}

lemma R3c_par_by_merge:
  assumes 
    "P is R1" "Q is R1" "P is CSP1" "Q is CSP1" "P is R3c" "Q is R3c" 
    "(wait\<^sub>m ;; M) = II\<lbrakk>true,true/$ok,$wait\<rbrakk>" "(div\<^sub>m ;; M) = R1(true)"
  shows "(P \<parallel>\<^bsub>M\<^esub> Q) is R3c"
proof -
  have "(P \<parallel>\<^bsub>M\<^esub> Q) = (((P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>true/$ok\<rbrakk> \<triangleleft> $ok \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>false/$ok\<rbrakk>)\<lbrakk>true/$wait\<rbrakk> \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (metis cond_idem cond_var_subst_left cond_var_subst_right vwb_lens_ok wait_vwb_lens)
  also have "... = (((P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>true,true/$ok,$wait\<rbrakk> \<triangleleft> $ok \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>false/$ok\<rbrakk>)\<lbrakk>true/$wait\<rbrakk> \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (rel_auto)
  also have "... = (((P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>true,true/$ok,$wait\<rbrakk> \<triangleleft> $ok \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>false/$ok\<rbrakk>) \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (metis cond_var_subst_left wait_vwb_lens)
  also have "... = ((II\<lbrakk>true,true/$ok,$wait\<rbrakk> \<triangleleft> $ok \<triangleright> R1(true)) \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
  proof -
    have "(P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>false/$ok\<rbrakk> = R1(true)"
    proof -
      have "(P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>false/$ok\<rbrakk> = ((P \<triangleleft> $ok \<triangleright> R1(true)) \<parallel>\<^bsub>M\<^esub> (Q \<triangleleft> $ok \<triangleright> R1(true)))\<lbrakk>false/$ok\<rbrakk>"
        by (metis CSP1_alt_def Healthy_if assms)
      also have "... = (R1(true) \<parallel>\<^bsub>M\<lbrakk>false/$ok\<^sub><\<rbrakk>\<^esub> R1(true))"
        by (rel_auto, metis, metis)
      also have "... = (div\<^sub>m ;; M)\<lbrakk>false/$ok\<rbrakk>"
        by (rel_auto, metis, metis)
      also have "... = (R1(true))\<lbrakk>false/$ok\<rbrakk>"
        by (simp add: assms(8))
      also have "... = (R1(true))"
        by rel_auto
      finally show ?thesis
        by simp
    qed
    moreover have "(P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>true,true/$ok,$wait\<rbrakk> = II\<lbrakk>true,true/$ok,$wait\<rbrakk>"
    proof -
      have "(P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>true,true/$ok,$wait\<rbrakk> = (P\<lbrakk>true,true/$ok,$wait\<rbrakk> \<parallel>\<^bsub>M\<^esub> Q\<lbrakk>true,true/$ok,$wait\<rbrakk>)\<lbrakk>true,true/$ok,$wait\<rbrakk>"
        by (rel_auto)
      also have "... = (((II \<triangleleft> $ok \<triangleright> R1(true)) \<triangleleft> $wait \<triangleright> P)\<lbrakk>true,true/$ok,$wait\<rbrakk> \<parallel>\<^bsub>M\<^esub> ((II \<triangleleft> $ok \<triangleright> R1(true)) \<triangleleft> $wait \<triangleright> Q)\<lbrakk>true,true/$ok,$wait\<rbrakk>)\<lbrakk>true,true/$ok,$wait\<rbrakk>"
        by (metis Healthy_def' R3c_cases assms(5) assms(6))
      also have "... = (II\<lbrakk>true,true/$ok,$wait\<rbrakk> \<parallel>\<^bsub>M\<^esub> II\<lbrakk>true,true/$ok,$wait\<rbrakk>)\<lbrakk>true,true/$ok,$wait\<rbrakk>"
        by (subst_tac)
      also have "... = (wait\<^sub>m ;; M)\<lbrakk>true,true/$ok,$wait\<rbrakk>"
        by (rel_auto)
      also have "... = II\<lbrakk>true,true/$ok,$wait\<rbrakk>"
        by (simp add: assms usubst)
      finally show ?thesis .
    qed
    ultimately show ?thesis by simp
  qed
  also have "... = ((II \<triangleleft> $ok \<triangleright> R1(true)) \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (rel_auto)
  also have "... = R3c(P \<parallel>\<^bsub>M\<^esub> Q)"
    by (simp add: R3c_cases)
  finally show ?thesis
    by (simp add: Healthy_def')
qed

lemma CSP1_par_by_merge:
  assumes "P is R1" "Q is R1" "P is CSP1" "Q is CSP1" "M is R1m" "(div\<^sub>m ;; M) = R1(true)"
  shows "(P \<parallel>\<^bsub>M\<^esub> Q) is CSP1"
proof -
  have "(P \<parallel>\<^bsub>M\<^esub> Q) = ((P \<parallel>\<^bsub>M\<^esub> Q) \<triangleleft> $ok \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>false/$ok\<rbrakk>)"
    by (metis cond_idem cond_var_subst_right vwb_lens_ok)
  also have "... = ((P \<parallel>\<^bsub>M\<^esub> Q) \<triangleleft> $ok \<triangleright> R1(true))"
  proof -
    have "(P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>false/$ok\<rbrakk> = ((P \<triangleleft> $ok \<triangleright> R1(true)) \<parallel>\<^bsub>M\<^esub> (Q \<triangleleft> $ok \<triangleright> R1(true)))\<lbrakk>false/$ok\<rbrakk>"
      by (metis CSP1_alt_def Healthy_if assms)
    also have "... = (R1(true) \<parallel>\<^bsub>M\<lbrakk>false/$ok\<^sub><\<rbrakk>\<^esub> R1(true))"
      by (rel_auto, metis, metis)
    also have "... = (div\<^sub>m ;; M)\<lbrakk>false/$ok\<rbrakk>"
      by (rel_auto, metis, metis)
    also have "... = (R1(true))\<lbrakk>false/$ok\<rbrakk>"
      by (simp add: assms(6))
    also have "... = (R1(true))"
      by rel_auto
    finally show ?thesis
      by simp
  qed
  finally show ?thesis
    by (metis CSP1_alt_def Healthy_def R1_par_by_merge assms(5))
qed

lemma CSP2_par_by_merge:
  assumes "M is CSP2"
  shows "(P \<parallel>\<^bsub>M\<^esub> Q) is CSP2"
proof -
  have "(P \<parallel>\<^bsub>M\<^esub> Q) = ((P \<parallel>\<^sub>s Q) ;; M)"
    by (simp add: par_by_merge_def)
  also from assms have "... = ((P \<parallel>\<^sub>s Q) ;; (M ;; J))"
    by (simp add: Healthy_def' CSP2_def H2_def)
  also from assms have "... = (((P \<parallel>\<^sub>s Q) ;; M) ;; J)"
    by (meson seqr_assoc)
  also from assms have "... = CSP2(P \<parallel>\<^bsub>M\<^esub> Q)"
    by (simp add: CSP2_def H2_def par_by_merge_def)
  finally show ?thesis
    by (simp add: Healthy_def')
qed


end
