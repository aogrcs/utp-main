section {* Reactive processes *}

theory utp_reactive
imports
  utp_designs
  utp_concurrency
  utp_event
begin

record 't::ordered_cancel_monoid_diff alpha_rp' =
  wait\<^sub>v :: bool
  tr\<^sub>v   :: "'t"

declare alpha_rp'.splits [alpha_splits]

text {*
  The two locale interpretations below are a technicality to improve automatic
  proof support via the predicate and relational tactics. This is to enable the
  (re-)interpretation of state spaces to remove any occurrences of lens types
  after the proof tactics @{method pred_simp} and @{method rel_simp}, or any
  of their derivatives have been applied. Eventually, it would be desirable to
  automate both interpretations as part of a custom outer command for defining
  alphabets.
*}

interpretation alphabet_rp:
  lens_interp "\<lambda>(ok, r). (ok, wait\<^sub>v r, tr\<^sub>v r, more r)"
apply (unfold_locales)
apply (rule injI)
apply (clarsimp)
done

interpretation alphabet_rp_rel: lens_interp "\<lambda>(ok, ok', r, r').
  (ok, ok', wait\<^sub>v r, wait\<^sub>v r', tr\<^sub>v r, tr\<^sub>v r', more r, more r')"
apply (unfold_locales)
apply (rule injI)
apply (clarsimp)
done

type_synonym ('t, '\<alpha>) alpha_rp_scheme = "('t, '\<alpha>) alpha_rp'_scheme alpha_d_scheme"

type_synonym ('t,'\<alpha>) alphabet_rp  = "('t,'\<alpha>) alpha_rp_scheme alphabet"
type_synonym ('t,'\<alpha>,'\<beta>) relation_rp  = "(('t,'\<alpha>) alphabet_rp, ('t,'\<beta>) alphabet_rp) relation"
type_synonym ('t,'\<alpha>) hrelation_rp  = "(('t,'\<alpha>) alphabet_rp, ('t,'\<alpha>) alphabet_rp) relation"
type_synonym ('t,'\<sigma>) predicate_rp  = "('t,'\<sigma>) alphabet_rp upred"

translations
  (type) "('t, '\<alpha>) alphabet_rp" <= (type) "('t, '\<alpha>) alpha_rp'_scheme alpha_d_ext"
  (type) "('t, '\<alpha>) alphabet_rp" <= (type) "('t, '\<alpha>) alpha_rp'_ext alpha_d_ext"

definition "wait\<^sub>r = VAR wait\<^sub>v"
definition "tr\<^sub>r   = VAR tr\<^sub>v"
definition "\<Sigma>\<^sub>r    = VAR more"

declare wait\<^sub>r_def [uvar_defs]
declare tr\<^sub>r_def [uvar_defs]
declare \<Sigma>\<^sub>r_def [uvar_defs]

lemma wait\<^sub>r_vwb_lens [simp]: "vwb_lens wait\<^sub>r"
  by (unfold_locales, simp_all add: wait\<^sub>r_def)

lemma tr\<^sub>r_vwb_lens [simp]: "vwb_lens tr\<^sub>r"
  by (unfold_locales, simp_all add: tr\<^sub>r_def)

lemma rea_vwb_lens [simp]: "vwb_lens \<Sigma>\<^sub>r"
  by (unfold_locales, simp_all add: \<Sigma>\<^sub>r_def)

definition [uvar_defs]: "wait = (wait\<^sub>r ;\<^sub>L \<Sigma>\<^sub>D)"
definition [uvar_defs]: "tr   = (tr\<^sub>r ;\<^sub>L \<Sigma>\<^sub>D)"
definition [uvar_defs]: "\<Sigma>\<^sub>R   = (\<Sigma>\<^sub>r ;\<^sub>L \<Sigma>\<^sub>D)"

lemma wait_vwb_lens [simp]: "vwb_lens wait"
  by (simp add: wait_def)

lemma tr_vwb_lens [simp]: "vwb_lens tr"
  by (simp add: tr_def)

lemma rea_lens_vwb_lens [simp]: "vwb_lens \<Sigma>\<^sub>R"
  by (simp add: \<Sigma>\<^sub>R_def)

lemma rea_lens_under_des_lens: "\<Sigma>\<^sub>R \<subseteq>\<^sub>L \<Sigma>\<^sub>D"
  by (simp add: \<Sigma>\<^sub>R_def lens_comp_lb)

lemma rea_lens_indep_ok [simp]: "\<Sigma>\<^sub>R \<bowtie> ok" "ok \<bowtie> \<Sigma>\<^sub>R"
  using ok_indep_des_lens(2) rea_lens_under_des_lens sublens_pres_indep apply blast
  using lens_indep_sym ok_indep_des_lens(2) rea_lens_under_des_lens sublens_pres_indep apply blast
done

lemma tr_ok_indep [simp]: "tr \<bowtie> ok" "ok \<bowtie> tr"
  by (simp_all add: lens_indep_left_ext lens_indep_sym tr_def)

lemma wait_ok_indep [simp]: "wait \<bowtie> ok" "ok \<bowtie> wait"
  by (simp_all add: lens_indep_left_ext lens_indep_sym wait_def)

lemma tr\<^sub>r_wait\<^sub>r_indep [simp]: "tr\<^sub>r \<bowtie> wait\<^sub>r" "wait\<^sub>r \<bowtie> tr\<^sub>r"
  by (auto intro!:lens_indepI simp add: tr\<^sub>r_def wait\<^sub>r_def)

lemma tr_wait_indep [simp]: "tr \<bowtie> wait" "wait \<bowtie> tr"
  by (auto intro: lens_indep_left_comp simp add: tr_def wait_def)

lemma rea_indep_wait [simp]: "\<Sigma>\<^sub>r \<bowtie> wait\<^sub>r" "wait\<^sub>r \<bowtie> \<Sigma>\<^sub>r"
  by (auto intro!:lens_indepI simp add: wait\<^sub>r_def \<Sigma>\<^sub>r_def)

lemma rea_lens_indep_wait [simp]: "\<Sigma>\<^sub>R \<bowtie> wait" "wait \<bowtie> \<Sigma>\<^sub>R"
  by (auto intro: lens_indep_left_comp simp add: wait_def \<Sigma>\<^sub>R_def)

lemma rea_indep_tr [simp]: "\<Sigma>\<^sub>r \<bowtie> tr\<^sub>r" "tr\<^sub>r \<bowtie> \<Sigma>\<^sub>r"
  by (auto intro!:lens_indepI simp add: tr\<^sub>r_def \<Sigma>\<^sub>r_def)

lemma rea_lens_indep_tr [simp]: "\<Sigma>\<^sub>R \<bowtie> tr" "tr \<bowtie> \<Sigma>\<^sub>R"
  by (auto intro: lens_indep_left_comp simp add: tr_def \<Sigma>\<^sub>R_def)

lemma rea_var_ords [usubst]:
  "$tr \<prec>\<^sub>v $tr\<acute>" "$wait \<prec>\<^sub>v $wait\<acute>"
  "$ok \<prec>\<^sub>v $tr" "$ok\<acute> \<prec>\<^sub>v $tr\<acute>" "$ok \<prec>\<^sub>v $tr\<acute>" "$ok\<acute> \<prec>\<^sub>v $tr"
  "$ok \<prec>\<^sub>v $wait" "$ok\<acute> \<prec>\<^sub>v $wait\<acute>" "$ok \<prec>\<^sub>v $wait\<acute>" "$ok\<acute> \<prec>\<^sub>v $wait"
  "$tr \<prec>\<^sub>v $wait" "$tr\<acute> \<prec>\<^sub>v $wait\<acute>" "$tr \<prec>\<^sub>v $wait\<acute>" "$tr\<acute> \<prec>\<^sub>v $wait"
  by (simp_all add: var_name_ord_def)

abbreviation wait_f::"('t::ordered_cancel_monoid_diff, '\<alpha>, '\<beta>) relation_rp \<Rightarrow> ('t, '\<alpha>, '\<beta>) relation_rp"
where "wait_f R \<equiv> R\<lbrakk>false/$wait\<rbrakk>"

abbreviation wait_t::"('t::ordered_cancel_monoid_diff, '\<alpha>, '\<beta>) relation_rp \<Rightarrow> ('t, '\<alpha>, '\<beta>) relation_rp"
where "wait_t R \<equiv> R\<lbrakk>true/$wait\<rbrakk>"

syntax
  "_wait_f"  :: "logic \<Rightarrow> logic" ("_\<^sub>f" [1000] 1000)
  "_wait_t"  :: "logic \<Rightarrow> logic" ("_\<^sub>t" [1000] 1000)

translations
  "P \<^sub>f" \<rightleftharpoons> "CONST usubst (CONST subst_upd CONST id (CONST ivar CONST wait) false) P"
  "P \<^sub>t" \<rightleftharpoons> "CONST usubst (CONST subst_upd CONST id (CONST ivar CONST wait) true) P"

abbreviation lift_rea :: "_ \<Rightarrow> _" ("\<lceil>_\<rceil>\<^sub>R") where
"\<lceil>P\<rceil>\<^sub>R \<equiv> P \<oplus>\<^sub>p (\<Sigma>\<^sub>R \<times>\<^sub>L \<Sigma>\<^sub>R)"

abbreviation drop_rea :: "('t::ordered_cancel_monoid_diff, '\<alpha>, '\<beta>) relation_rp \<Rightarrow> ('\<alpha>, '\<beta>) relation" ("\<lfloor>_\<rfloor>\<^sub>R") where
"\<lfloor>P\<rfloor>\<^sub>R \<equiv> P \<restriction>\<^sub>p (\<Sigma>\<^sub>R \<times>\<^sub>L \<Sigma>\<^sub>R)"

abbreviation rea_pre_lift :: "_ \<Rightarrow> _" ("\<lceil>_\<rceil>\<^sub>R\<^sub><") where "\<lceil>n\<rceil>\<^sub>R\<^sub>< \<equiv> \<lceil>\<lceil>n\<rceil>\<^sub><\<rceil>\<^sub>R"

definition skip_rea_def [urel_defs]: "II\<^sub>r = (II \<or> (\<not> $ok \<and> $tr \<le>\<^sub>u $tr\<acute>))"

(* Instantiate the vstore for reactive alphabets *)

instantiation alpha_rp'_ext :: (ordered_cancel_monoid_diff,vst) vst
begin
  definition vstore_lens_alpha_rp'_ext :: "vstore \<Longrightarrow> ('a, 'b) alpha_rp'_scheme" where
  "vstore_lens_alpha_rp'_ext = \<V> ;\<^sub>L \<Sigma>\<^sub>r"
instance
  by (intro_classes, simp add: vstore_lens_alpha_rp'_ext_def)
end

subsection {* Reactive lemmas *}

lemma unrest_ok_lift_rea [unrest]:
  "$ok \<sharp> \<lceil>P\<rceil>\<^sub>R" "$ok\<acute> \<sharp> \<lceil>P\<rceil>\<^sub>R"
  by (pred_auto)+

lemma unrest_wait_lift_rea [unrest]:
  "$wait \<sharp> \<lceil>P\<rceil>\<^sub>R" "$wait\<acute> \<sharp> \<lceil>P\<rceil>\<^sub>R"
  by (pred_auto)+

lemma unrest_tr_lift_rea [unrest]:
  "$tr \<sharp> \<lceil>P\<rceil>\<^sub>R" "$tr\<acute> \<sharp> \<lceil>P\<rceil>\<^sub>R"
  by (pred_auto)+

lemma tr_prefix_as_concat: "(xs \<le>\<^sub>u ys) = (\<^bold>\<exists> zs \<bullet> ys =\<^sub>u xs ^\<^sub>u \<guillemotleft>zs\<guillemotright>)"
  by (rel_auto, simp add: less_eq_list_def prefixeq_def)

lemma seqr_wait_true [usubst]: "(P ;; Q) \<^sub>t = (P \<^sub>t ;; Q)"
  by rel_auto

lemma seqr_wait_false [usubst]: "(P ;; Q) \<^sub>f = (P \<^sub>f ;; Q)"
  by rel_auto

subsection {* R1: Events cannot be undone *}

definition R1_def [upred_defs]: "R1 (P) =  (P \<and> ($tr \<le>\<^sub>u $tr\<acute>))"

lemma R1_idem: "R1(R1(P)) = R1(P)"
  by pred_auto

lemma R1_Idempotent: "Idempotent R1"
  by (simp add: Idempotent_def R1_idem)

lemma R1_mono: "P \<sqsubseteq> Q \<Longrightarrow> R1(P) \<sqsubseteq> R1(Q)"
  by pred_auto

lemma R1_Monotonic: "Monotonic R1"
  by (simp add: Monotonic_def R1_mono)

lemma R1_unrest [unrest]: "\<lbrakk> x \<bowtie> in_var tr; x \<bowtie> out_var tr; x \<sharp> P \<rbrakk> \<Longrightarrow> x \<sharp> R1(P)"
  by (metis R1_def in_var_uvar lens_indep_sym out_var_uvar tr_vwb_lens unrest_bop unrest_conj unrest_var)

lemma R1_false: "R1(false) = false"
  by pred_auto

lemma R1_conj: "R1(P \<and> Q) = (R1(P) \<and> R1(Q))"
  by pred_auto

lemma R1_disj: "R1(P \<or> Q) = (R1(P) \<or> R1(Q))"
  by pred_auto

lemma R1_USUP:
  "R1(\<Sqinter> i \<in> A \<bullet> P(i)) = (\<Sqinter> i \<in> A \<bullet> R1(P(i)))"
  by (rel_auto)

lemma R1_UINF:
  assumes "A \<noteq> {}"
  shows "R1(\<Squnion> i \<in> A \<bullet> P(i)) = (\<Squnion> i \<in> A \<bullet> R1(P(i)))"
  using assms by (rel_auto)

lemma R1_extend_conj: "R1(P \<and> Q) = (R1(P) \<and> Q)"
  by pred_auto

lemma R1_extend_conj': "R1(P \<and> Q) = (P \<and> R1(Q))"
  by pred_auto

lemma R1_cond: "R1(P \<triangleleft> b \<triangleright> Q) = (R1(P) \<triangleleft> b \<triangleright> R1(Q))"
  by rel_auto

lemma R1_negate_R1: "R1(\<not> R1(P)) = R1(\<not> P)"
  by pred_auto

lemma R1_wait_true: "(R1 P)\<^sub>t = R1(P)\<^sub>t"
  by pred_auto

lemma R1_wait_false: "(R1 P) \<^sub>f = R1(P) \<^sub>f"
  by pred_auto

lemma R1_skip: "R1(II) = II"
  by rel_auto

lemma R1_skip_rea: "R1(II\<^sub>r) = II\<^sub>r"
  by rel_auto

lemma skip_rea_form: "II\<^sub>r = (II \<triangleleft> $ok \<triangleright> R1(true))"
  by rel_auto

lemma R1_by_refinement:
  "P is R1 \<longleftrightarrow> (($tr \<le>\<^sub>u $tr\<acute>) \<sqsubseteq> P)"
  by rel_blast

lemma tr_le_trans:
  "($tr \<le>\<^sub>u $tr\<acute> ;; $tr \<le>\<^sub>u $tr\<acute>) = ($tr \<le>\<^sub>u $tr\<acute>)"
  by (rel_auto)

lemma R1_seqr:
  "R1(R1(P) ;; R1(Q)) = (R1(P) ;; R1(Q))"
  by (rel_auto)

lemma R1_seqr_closure:
  assumes "P is R1" "Q is R1"
  shows "(P ;; Q) is R1"
  using assms unfolding R1_by_refinement
  by (metis seqr_mono tr_le_trans)

lemma R1_true_comp: "(R1(true) ;; R1(true)) = R1(true)"
  by (rel_auto)

lemma R1_ok'_true: "(R1(P))\<^sup>t = R1(P\<^sup>t)"
  by pred_auto

lemma R1_ok'_false: "(R1(P))\<^sup>f = R1(P\<^sup>f)"
  by pred_auto

lemma R1_ok_true: "(R1(P))\<lbrakk>true/$ok\<rbrakk> = R1(P\<lbrakk>true/$ok\<rbrakk>)"
  by pred_auto

lemma R1_ok_false: "(R1(P))\<lbrakk>false/$ok\<rbrakk> = R1(P\<lbrakk>false/$ok\<rbrakk>)"
  by pred_auto

lemma seqr_R1_true_right: "((P ;; R1(true)) \<or> P) = (P ;; ($tr \<le>\<^sub>u $tr\<acute>))"
  by rel_auto

lemma R1_extend_conj_unrest: "\<lbrakk> $tr \<sharp> Q; $tr\<acute> \<sharp> Q \<rbrakk> \<Longrightarrow> R1(P \<and> Q) = (R1(P) \<and> Q)"
  by pred_auto

lemma R1_extend_conj_unrest': "\<lbrakk> $tr \<sharp> P; $tr\<acute> \<sharp> P \<rbrakk> \<Longrightarrow> R1(P \<and> Q) = (P \<and> R1(Q))"
  by pred_auto

lemma R1_tr'_eq_tr: "R1($tr\<acute> =\<^sub>u $tr) = ($tr\<acute> =\<^sub>u $tr)"
  by (rel_auto)

lemma R1_H2_commute: "R1(H2(P)) = H2(R1(P))"
  by (simp add: H2_split R1_def usubst, rel_auto)

subsection {* R2 *}

definition R2a_def [upred_defs]: "R2a (P) = (\<Sqinter> s \<bullet> P\<lbrakk>\<guillemotleft>s\<guillemotright>,\<guillemotleft>s\<guillemotright>+($tr\<acute>-$tr)/$tr,$tr\<acute>\<rbrakk>)"
definition R2a'_def [upred_defs]: "R2a' (P) = (R2a(P) \<triangleleft> R1(true) \<triangleright> P)"
definition R2s_def [upred_defs]: "R2s (P) = (P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>($tr\<acute>-$tr)/$tr\<acute>\<rbrakk>)"
definition R2_def  [upred_defs]: "R2(P) = R1(R2s(P))"
definition R2c_def [upred_defs]: "R2c(P) = (R2s(P) \<triangleleft> R1(true) \<triangleright> P)"

lemma R2a_R2s: "R2a(R2s(P)) = R2s(P)"
  by rel_auto

lemma R2s_R2a: "R2s(R2a(P)) = R2a(P)"
  by rel_auto

lemma R2a_equiv_R2s: "P is R2a \<longleftrightarrow> P is R2s"
  by (metis Healthy_def' R2a_R2s R2s_R2a)

lemma R2a_idem: "R2a(R2a(P)) = R2a(P)"
  by (rel_auto)

lemma R2a'_idem: "R2a'(R2a'(P)) = R2a'(P)"
  by (rel_auto)

lemma R2a_mono: "P \<sqsubseteq> Q \<Longrightarrow> R2a(P) \<sqsubseteq> R2a(Q)"
  by (rel_auto, rule Sup_mono, blast)

lemma R2a'_mono: "P \<sqsubseteq> Q \<Longrightarrow> R2a'(P) \<sqsubseteq> R2a'(Q)"
  by (rel_auto, blast)

lemma R2a'_weakening: "R2a'(P) \<sqsubseteq> P"
  apply (rel_auto)
  apply (rename_tac ok wait tr more ok' wait' tr' more')
  apply (rule_tac x="tr" in exI)
  apply (simp add: diff_add_cancel_left')
done

lemma R2s_idem: "R2s(R2s(P)) = R2s(P)"
  by (pred_auto)

lemma R2s_unrest [unrest]: "\<lbrakk> vwb_lens x; x \<bowtie> in_var tr; x \<bowtie> out_var tr; x \<sharp> P \<rbrakk> \<Longrightarrow> x \<sharp> R2s(P)"
  by (simp add: R2s_def unrest usubst lens_indep_sym)

lemma R2_idem: "R2(R2(P)) = R2(P)"
  by (pred_auto)

lemma R2_mono: "P \<sqsubseteq> Q \<Longrightarrow> R2(P) \<sqsubseteq> R2(Q)"
  by (pred_auto)

lemma R2s_conj: "R2s(P \<and> Q) = (R2s(P) \<and> R2s(Q))"
  by (pred_auto)

lemma R2_conj: "R2(P \<and> Q) = (R2(P) \<and> R2(Q))"
  by (pred_auto)

lemma R2s_disj: "R2s(P \<or> Q) = (R2s(P) \<or> R2s(Q))"
  by pred_auto

lemma R2s_USUP:
  "R2s(\<Sqinter> i \<in> A \<bullet> P(i)) = (\<Sqinter> i \<in> A \<bullet> R2s(P(i)))"
  by (simp add: R2s_def usubst)

lemma R2c_USUP:
  "R2c(\<Sqinter> i \<in> A \<bullet> P(i)) = (\<Sqinter> i \<in> A \<bullet> R2c(P(i)))"
  by (rel_auto)

lemma R2s_UINF:
  "R2s(\<Squnion> i \<in> A \<bullet> P(i)) = (\<Squnion> i \<in> A \<bullet> R2s(P(i)))"
  by (simp add: R2s_def usubst)

lemma R2c_UINF:
  "R2c(\<Squnion> i \<in> A \<bullet> P(i)) = (\<Squnion> i \<in> A \<bullet> R2c(P(i)))"
  by (rel_auto)

lemma R2_disj: "R2(P \<or> Q) = (R2(P) \<or> R2(Q))"
  by (pred_auto)

lemma R2s_not: "R2s(\<not> P) = (\<not> R2s(P))"
  by pred_auto

lemma R2s_condr: "R2s(P \<triangleleft> b \<triangleright> Q) = (R2s(P) \<triangleleft> R2s(b) \<triangleright> R2s(Q))"
  by rel_auto

lemma R2_condr: "R2(P \<triangleleft> b \<triangleright> Q) = (R2(P) \<triangleleft> R2(b) \<triangleright> R2(Q))"
  by rel_auto

lemma R2_condr': "R2(P \<triangleleft> b \<triangleright> Q) = (R2(P) \<triangleleft> R2s(b) \<triangleright> R2(Q))"
  by rel_auto

lemma R2s_ok: "R2s($ok) = $ok"
  by rel_auto

lemma R2s_ok': "R2s($ok\<acute>) = $ok\<acute>"
  by rel_auto

lemma R2s_wait: "R2s($wait) = $wait"
  by rel_auto

lemma R2s_wait': "R2s($wait\<acute>) = $wait\<acute>"
  by rel_auto

lemma R2s_true: "R2s(true) = true"
  by pred_auto

lemma R2s_false: "R2s(false) = false"
  by pred_auto

lemma true_is_R2s:
  "true is R2s"
  by (simp add: Healthy_def R2s_true)

lemma R2s_lift_rea: "R2s(\<lceil>P\<rceil>\<^sub>R) = \<lceil>P\<rceil>\<^sub>R"
  by (simp add: R2s_def usubst unrest)

lemma R2c_true: "R2c(true) = true"
  by rel_auto

lemma R2c_false: "R2c(false) = false"
  by rel_auto

lemma R2c_and: "R2c(P \<and> Q) = (R2c(P) \<and> R2c(Q))"
  by (rel_auto)

lemma R2c_disj: "R2c(P \<or> Q) = (R2c(P) \<or> R2c(Q))"
  by (rel_auto)

lemma R2c_not: "R2c(\<not> P) = (\<not> R2c(P))"
  by (rel_auto)

lemma R2c_ok: "R2c($ok) = ($ok)"
  by (rel_auto)

lemma R2c_ok': "R2c($ok\<acute>) = ($ok\<acute>)"
  by (rel_auto)

lemma R2c_wait: "R2c($wait) = $wait"
  by (rel_auto)

lemma R2c_tr'_minus_tr: "R2c($tr\<acute> =\<^sub>u $tr) = ($tr\<acute> =\<^sub>u $tr)"
  apply (rel_auto) using minus_zero_eq by blast

lemma R2c_tr'_ge_tr: "R2c($tr\<acute> \<ge>\<^sub>u $tr) = ($tr\<acute> \<ge>\<^sub>u $tr)"
  by (rel_auto)

lemma R2c_condr: "R2c(P \<triangleleft> b \<triangleright> Q) = (R2c(P) \<triangleleft> R2c(b) \<triangleright> R2c(Q))"
  by (rel_auto)

lemma R2c_skip_r: "R2c(II) = II"
proof -
  have "R2c(II) = R2c($tr\<acute> =\<^sub>u $tr \<and> II\<restriction>\<^sub>\<alpha>tr)"
    by (subst skip_r_unfold[of tr], simp_all)
  also have "... = (R2c($tr\<acute> =\<^sub>u $tr) \<and> II\<restriction>\<^sub>\<alpha>tr)"
    by (simp add: R2c_and, simp add: R2c_def R2s_def usubst unrest cond_idem)
  also have "... = ($tr\<acute> =\<^sub>u $tr \<and> II\<restriction>\<^sub>\<alpha>tr)"
    by (simp add: R2c_tr'_minus_tr)
  finally show ?thesis
    by (subst skip_r_unfold[of tr], simp_all)
qed

lemma R1_R2c_commute: "R1(R2c(P)) = R2c(R1(P))"
  by (rel_auto)

lemma R1_R2c_is_R2: "R1(R2c(P)) = R2(P)"
  by (rel_auto)

lemma R2c_skip_rea: "R2c II\<^sub>r = II\<^sub>r"
  by (simp add: skip_rea_def R2c_and R2c_disj R2c_skip_r R2c_not R2c_ok R2c_tr'_ge_tr)

lemma R1_R2s_R2c: "R1(R2s(P)) = R1(R2c(P))"
  by (rel_auto)

lemma R2_skip_rea: "R2(II\<^sub>r) = II\<^sub>r"
  by (metis R1_R2c_is_R2 R1_skip_rea R2c_skip_rea)

lemma R2_tr_prefix: "R2($tr \<le>\<^sub>u $tr\<acute>) = ($tr \<le>\<^sub>u $tr\<acute>)"
  by (pred_auto)

lemma R2_form:
  "R2(P) = (\<^bold>\<exists> tt \<bullet> P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<guillemotright>/$tr\<acute>\<rbrakk> \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<guillemotright>)"
  by (rel_auto, metis ordered_cancel_monoid_diff_class.add_diff_cancel_left ordered_cancel_monoid_diff_class.le_iff_add)

lemma R2_seqr_form:
  shows "(R2(P) ;; R2(Q)) =
         (\<^bold>\<exists> tt\<^sub>1 \<bullet> \<^bold>\<exists> tt\<^sub>2 \<bullet> ((P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<acute>\<rbrakk>) ;; (Q\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>2\<guillemotright>/$tr\<acute>\<rbrakk>))
                        \<and> ($tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>))"
proof -
  have "(R2(P) ;; R2(Q)) = (\<^bold>\<exists> tr\<^sub>0 \<bullet> (R2(P))\<lbrakk>\<guillemotleft>tr\<^sub>0\<guillemotright>/$tr\<acute>\<rbrakk> ;; (R2(Q))\<lbrakk>\<guillemotleft>tr\<^sub>0\<guillemotright>/$tr\<rbrakk>)"
    by (subst seqr_middle[of tr], simp_all)
  also have "... =
       (\<^bold>\<exists> tr\<^sub>0 \<bullet> \<^bold>\<exists> tt\<^sub>1 \<bullet> \<^bold>\<exists> tt\<^sub>2 \<bullet> ((P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<acute>\<rbrakk> \<and> \<guillemotleft>tr\<^sub>0\<guillemotright> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright>) ;;
                                (Q\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>2\<guillemotright>/$tr\<acute>\<rbrakk> \<and> $tr\<acute> =\<^sub>u \<guillemotleft>tr\<^sub>0\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>)))"
    by (simp add: R2_form usubst unrest uquant_lift, rel_blast)
  also have "... =
       (\<^bold>\<exists> tr\<^sub>0 \<bullet> \<^bold>\<exists> tt\<^sub>1 \<bullet> \<^bold>\<exists> tt\<^sub>2 \<bullet> ((\<guillemotleft>tr\<^sub>0\<guillemotright> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright> \<and> P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<acute>\<rbrakk>) ;;
                                (Q\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>2\<guillemotright>/$tr\<acute>\<rbrakk> \<and> $tr\<acute> =\<^sub>u \<guillemotleft>tr\<^sub>0\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>)))"
    by (simp add: conj_comm)
  also have "... =
       (\<^bold>\<exists> tt\<^sub>1 \<bullet> \<^bold>\<exists> tt\<^sub>2 \<bullet> \<^bold>\<exists> tr\<^sub>0 \<bullet> ((P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<acute>\<rbrakk>) ;; (Q\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>2\<guillemotright>/$tr\<acute>\<rbrakk>))
                                \<and> \<guillemotleft>tr\<^sub>0\<guillemotright> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright> \<and> $tr\<acute> =\<^sub>u \<guillemotleft>tr\<^sub>0\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>)"
    by rel_blast
  also have "... =
       (\<^bold>\<exists> tt\<^sub>1 \<bullet> \<^bold>\<exists> tt\<^sub>2 \<bullet> ((P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<acute>\<rbrakk>) ;; (Q\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>2\<guillemotright>/$tr\<acute>\<rbrakk>))
                        \<and> (\<^bold>\<exists> tr\<^sub>0 \<bullet> \<guillemotleft>tr\<^sub>0\<guillemotright> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright> \<and> $tr\<acute> =\<^sub>u \<guillemotleft>tr\<^sub>0\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>))"
    by rel_auto
  also have "... =
       (\<^bold>\<exists> tt\<^sub>1 \<bullet> \<^bold>\<exists> tt\<^sub>2 \<bullet> ((P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<acute>\<rbrakk>) ;; (Q\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>2\<guillemotright>/$tr\<acute>\<rbrakk>))
                        \<and> ($tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>))"
    by rel_auto
  finally show ?thesis .
qed

lemma R2_seqr_distribute:
  fixes P :: "('t::ordered_cancel_monoid_diff,'\<alpha>,'\<beta>) relation_rp" and Q :: "('t,'\<beta>,'\<gamma>) relation_rp"
  shows "R2(R2(P) ;; R2(Q)) = (R2(P) ;; R2(Q))"
proof -
  have "R2(R2(P) ;; R2(Q)) =
    ((\<^bold>\<exists> tt\<^sub>1 \<bullet> \<^bold>\<exists> tt\<^sub>2 \<bullet> (P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<acute>\<rbrakk> ;; Q\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>2\<guillemotright>/$tr\<acute>\<rbrakk>)\<lbrakk>($tr\<acute> - $tr)/$tr\<acute>\<rbrakk>
      \<and> $tr\<acute> - $tr =\<^sub>u \<guillemotleft>tt\<^sub>1\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>) \<and> $tr\<acute> \<ge>\<^sub>u $tr)"
    by (simp add: R2_seqr_form, simp add: R2s_def usubst unrest, rel_auto)
  also have "... =
    ((\<^bold>\<exists> tt\<^sub>1 \<bullet> \<^bold>\<exists> tt\<^sub>2 \<bullet> (P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<acute>\<rbrakk> ;; Q\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>2\<guillemotright>/$tr\<acute>\<rbrakk>)\<lbrakk>(\<guillemotleft>tt\<^sub>1\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>)/$tr\<acute>\<rbrakk>
      \<and> $tr\<acute> - $tr =\<^sub>u \<guillemotleft>tt\<^sub>1\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>) \<and> $tr\<acute> \<ge>\<^sub>u $tr)"
      by (subst subst_eq_replace, simp)
  also have "... =
    ((\<^bold>\<exists> tt\<^sub>1 \<bullet> \<^bold>\<exists> tt\<^sub>2 \<bullet> (P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<acute>\<rbrakk> ;; Q\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>2\<guillemotright>/$tr\<acute>\<rbrakk>)
      \<and> $tr\<acute> - $tr =\<^sub>u \<guillemotleft>tt\<^sub>1\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>) \<and> $tr\<acute> \<ge>\<^sub>u $tr)"
      by (rel_auto)
  also have "... =
    (\<^bold>\<exists> tt\<^sub>1 \<bullet> \<^bold>\<exists> tt\<^sub>2 \<bullet> (P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<acute>\<rbrakk> ;; Q\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>2\<guillemotright>/$tr\<acute>\<rbrakk>)
      \<and> ($tr\<acute> - $tr =\<^sub>u \<guillemotleft>tt\<^sub>1\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright> \<and> $tr\<acute> \<ge>\<^sub>u $tr))"
    by pred_auto
  also have "... =
    ((\<^bold>\<exists> tt\<^sub>1 \<bullet> \<^bold>\<exists> tt\<^sub>2 \<bullet> (P\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<acute>\<rbrakk> ;; Q\<lbrakk>0/$tr\<rbrakk>\<lbrakk>\<guillemotleft>tt\<^sub>2\<guillemotright>/$tr\<acute>\<rbrakk>)
      \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>))"
  proof -
    have "\<And> tt\<^sub>1 tt\<^sub>2. ((($tr\<acute> - $tr =\<^sub>u \<guillemotleft>tt\<^sub>1\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>) \<and> $tr\<acute> \<ge>\<^sub>u $tr) :: ('t,'\<alpha>,'\<gamma>) relation_rp)
           = ($tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright> + \<guillemotleft>tt\<^sub>2\<guillemotright>)"
      apply (rel_auto)
      apply (metis add.assoc diff_add_cancel_left')
      apply (simp add: add.assoc)
      apply (meson le_add order_trans)
    done
    thus ?thesis by simp
  qed
  also have "... = (R2(P) ;; R2(Q))"
    by (simp add: R2_seqr_form)
  finally show ?thesis .
qed

lemma R2_seqr_closure:
  assumes "P is R2" "Q is R2"
  shows "(P ;; Q) is R2"
  by (metis Healthy_def' R2_seqr_distribute assms(1) assms(2))

lemma R1_R2_commute:
  "R1(R2(P)) = R2(R1(P))"
  by pred_auto

lemma R2_R1_form: "R2(R1(P)) = R1(R2s(P))"
  by (rel_auto)

lemma R2s_H1_commute:
  "R2s(H1(P)) = H1(R2s(P))"
  by rel_auto

lemma R2s_H2_commute:
  "R2s(H2(P)) = H2(R2s(P))"
  by (simp add: H2_split R2s_def usubst)

lemma R2_R1_seq_drop_left:
  "R2(R1(P) ;; R1(Q)) = R2(P ;; R1(Q))"
  by rel_auto

lemma R2c_idem: "R2c(R2c(P)) = R2c(P)"
  by (rel_auto)

lemma R2c_Idempotent: "Idempotent R2c"
  by (simp add: Idempotent_def R2c_idem)

lemma R2c_Monotonic: "Monotonic R2c"
  by (rel_auto)

lemma R2c_H2_commute: "R2c(H2(P)) = H2(R2c(P))"
  by (simp add: H2_split R2c_disj R2c_def R2s_def usubst, rel_auto)

lemma R2c_seq: "R2c(R2(P) ;; R2(Q)) = (R2(P) ;; R2(Q))"
  by (metis (no_types, lifting) R1_R2c_commute R1_R2c_is_R2 R2_seqr_distribute R2c_idem)

lemma R2_R2c_def: "R2(P) = R1(R2c(P))"
  by rel_auto

lemma R2c_R1_seq: "R2c(R1(R2c(P)) ;; R1(R2c(Q))) = (R1(R2c(P)) ;; R1(R2c(Q)))"
  using R2c_seq[of P Q] by (simp add: R2_R2c_def)

subsection {* R3 *}

definition R3_def [upred_defs]: "R3(P) = (II \<triangleleft> $wait \<triangleright> P)"

definition R3c_def [upred_defs]: "R3c(P) = (II\<^sub>r \<triangleleft> $wait \<triangleright> P)"

text {* R3 as presented in the UTP book and related publications is not sensitive to state, for
  this we need a modification from Butterfield et al. (2009) that explicitly states that intermediate
  waiting states do not propogate final state variables. In order to do this we need an additional
  observational variable that capture the program state that we call $st$. *}

record 's alpha_state =
  st\<^sub>v :: 's

type_synonym ('s, 't, '\<alpha>) alpha_rsp_scheme = "('t, ('s, '\<alpha>) alpha_state_scheme) alpha_rp'_scheme alpha_d_scheme"

type_synonym ('s, 't,'\<alpha>) alphabet_rsp = "('s, 't,'\<alpha>) alpha_rsp_scheme alphabet"
type_synonym ('s,'t,'\<alpha>,'\<beta>) relation_rsp  = "(('s,'t,'\<alpha>) alphabet_rsp, ('s,'t,'\<beta>) alphabet_rsp) relation"
type_synonym ('s,'t,'\<alpha>) hrelation_rsp  = "(('s,'t,'\<alpha>) alphabet_rsp, ('s,'t,'\<alpha>) alphabet_rsp) relation"

translations
  (type) "('s, 't, '\<alpha>) alphabet_rsp" <= (type) "('t, ('s, '\<alpha>) alpha_state_scheme) alpha_rp'_scheme alpha_d_scheme"

declare alpha_state.splits [alpha_splits]

interpretation alphabet_state:
  lens_interp "\<lambda>(ok, wait, tr, r). (ok, wait, tr, st\<^sub>v r, more r)"
apply (unfold_locales)
apply (rule injI)
apply (clarsimp)
done

interpretation alphabet_state_rel: lens_interp "\<lambda>(ok, ok', wait, wait', tr, tr', r, r').
  (ok, ok', wait, wait', tr, tr', st\<^sub>v r, st\<^sub>v r', more r, more r')"
apply (unfold_locales)
apply (rule injI)
apply (clarsimp)
done

definition "st\<^sub>r = VAR st\<^sub>v"
definition "\<Sigma>\<^sub>s    = VAR more"

declare st\<^sub>r_def [uvar_defs]
declare \<Sigma>\<^sub>s_def [uvar_defs]

lemma st\<^sub>r_vwb_lens [simp]: "vwb_lens st\<^sub>r"
  by (unfold_locales, simp_all add: st\<^sub>r_def)

lemma stext_vwb_lens [simp]: "vwb_lens \<Sigma>\<^sub>s"
  by (unfold_locales, simp_all add: \<Sigma>\<^sub>s_def)

definition [uvar_defs]: "st = (st\<^sub>r ;\<^sub>L \<Sigma>\<^sub>R)"

lemma st_vwb_lens [simp]: "vwb_lens st"
  by (simp add: st_def)

lemma st_ok_indep [simp]: "st \<bowtie> ok" "ok \<bowtie> st"
  by (simp_all add: lens_indep_left_ext lens_indep_sym st_def)

lemma st_wait_indep [simp]: "st \<bowtie> wait" "wait \<bowtie> st"
  by (simp_all add: lens_indep_left_ext lens_indep_sym st_def)

lemma st_tr_indep [simp]: "st \<bowtie> tr" "tr \<bowtie> st"
  by (simp_all add: lens_indep_left_ext lens_indep_sym st_def)

definition R3h_def [upred_defs]: "R3h(P) = ((\<exists> $st \<bullet> II\<^sub>r) \<triangleleft> $wait \<triangleright> P)"

definition skip_rea3_def [urel_defs]: "II\<^sub>R = ((\<exists> $st \<bullet> II\<^sub>r) \<triangleleft> $wait \<triangleright> II\<^sub>r)"

lemma R2c_skip_rea3: "R2c(II\<^sub>R) = II\<^sub>R"
  apply (rel_auto) using minus_zero_eq by blast+

lemma R3_idem: "R3(R3(P)) = R3(P)"
  by rel_auto

lemma R3_Idempotent: "Idempotent R3"
  by (simp add: Idempotent_def R3_idem)

lemma R3_mono: "P \<sqsubseteq> Q \<Longrightarrow> R3(P) \<sqsubseteq> R3(Q)"
  by rel_auto

lemma R3_Monotonic: "Monotonic R3"
  by (simp add: Monotonic_def R3_mono)

lemma R3_conj: "R3(P \<and> Q) = (R3(P) \<and> R3(Q))"
  by rel_auto

lemma R3_disj: "R3(P \<or> Q) = (R3(P) \<or> R3(Q))"
  by rel_auto

lemma R3_USUP:
  assumes "A \<noteq> {}"
  shows "R3(\<Sqinter> i \<in> A \<bullet> P(i)) = (\<Sqinter> i \<in> A \<bullet> R3(P(i)))"
  using assms by (rel_auto)

lemma R3_UINF:
  assumes "A \<noteq> {}"
  shows "R3(\<Squnion> i \<in> A \<bullet> P(i)) = (\<Squnion> i \<in> A \<bullet> R3(P(i)))"
  using assms by (rel_auto)

lemma R3_condr: "R3(P \<triangleleft> b \<triangleright> Q) = (R3(P) \<triangleleft> b \<triangleright> R3(Q))"
  by rel_auto

lemma R3_skipr: "R3(II) = II"
  by rel_auto

lemma R3_form: "R3(P) = (($wait \<and> II) \<or> (\<not> $wait \<and> P))"
  by rel_auto

lemma wait_R3:
  "($wait \<and> R3(P)) = (II \<and> $wait\<acute>)"
  by (rel_auto)

lemma nwait_R3:
  "(\<not>$wait \<and> R3(P)) = (\<not>$wait \<and> P)"
  by (rel_auto)

lemma R3_semir_form:
  "(R3(P) ;; R3(Q)) = R3(P ;; R3(Q))"
  by rel_auto

lemma R3_semir_closure:
  assumes "P is R3" "Q is R3"
  shows "(P ;; Q) is R3"
  using assms
  by (metis Healthy_def' R3_semir_form)

lemma R3c_semir_form:
  "(R3c(P) ;; R3c(R1(Q))) = R3c(P ;; R3c(R1(Q)))"
  by (rel_simp, safe, auto intro: order_trans)

lemma R3h_semir_form:
  "(R3h(P) ;; R3h(R1(Q))) = R3h(P ;; R3h(R1(Q)))"
  by (rel_simp, safe, auto intro: order_trans, blast+)

lemma R3c_seq_closure:
  assumes "P is R3c" "Q is R3c" "Q is R1"
  shows "(P ;; Q) is R3c"
  by (metis Healthy_def' R3c_semir_form assms)

lemma R3h_seq_closure:
  assumes "P is R3h" "Q is R3h" "Q is R1"
  shows "(P ;; Q) is R3h"
  by (metis Healthy_def' R3h_semir_form assms)

lemma R3c_R3_left_seq_closure:
  assumes "P is R3" "Q is R3c"
  shows "(P ;; Q) is R3c"
proof -
  have "(P ;; Q) = ((P ;; Q)\<lbrakk>true/$wait\<rbrakk> \<triangleleft> $wait \<triangleright> (P ;; Q))"
    by (metis cond_var_split cond_var_subst_right in_var_uvar wait_vwb_lens)
  also have "... = (((II \<triangleleft> $wait \<triangleright> P) ;; Q)\<lbrakk>true/$wait\<rbrakk> \<triangleleft> $wait \<triangleright> (P ;; Q))"
    by (metis Healthy_def' R3_def assms(1))
  also have "... = ((II\<lbrakk>true/$wait\<rbrakk> ;; Q) \<triangleleft> $wait \<triangleright> (P ;; Q))"
    by (subst_tac)
  also have "... = ((II \<and> $wait\<acute> ;; Q) \<triangleleft> $wait \<triangleright> (P ;; Q))"
    by (metis (no_types, lifting) cond_def conj_pos_var_subst seqr_pre_var_out skip_var utp_pred.inf_left_idem wait_vwb_lens)
  also have "... = ((II\<lbrakk>true/$wait\<acute>\<rbrakk> ;; Q\<lbrakk>true/$wait\<rbrakk>) \<triangleleft> $wait \<triangleright> (P ;; Q))"
    by (metis seqr_pre_transfer seqr_right_one_point true_alt_def uovar_convr upred_eq_true utp_rel.unrest_ouvar vwb_lens_mwb wait_vwb_lens)
  also have "... = ((II\<lbrakk>true/$wait\<acute>\<rbrakk> ;; (II\<^sub>r \<triangleleft> $wait \<triangleright> Q)\<lbrakk>true/$wait\<rbrakk>) \<triangleleft> $wait \<triangleright> (P ;; Q))"
    by (metis Healthy_def' R3c_def assms(2))
  also have "... = ((II\<lbrakk>true/$wait\<acute>\<rbrakk> ;; II\<^sub>r\<lbrakk>true/$wait\<rbrakk>) \<triangleleft> $wait \<triangleright> (P ;; Q))"
    by (subst_tac)
  also have "... = ((II \<and> $wait\<acute> ;; II\<^sub>r) \<triangleleft> $wait \<triangleright> (P ;; Q))"
    by (metis seqr_pre_transfer seqr_right_one_point true_alt_def uovar_convr upred_eq_true utp_rel.unrest_ouvar vwb_lens_mwb wait_vwb_lens)
  also have "... = ((II ;; II\<^sub>r) \<triangleleft> $wait \<triangleright> (P ;; Q))"
    by (simp add: cond_def seqr_pre_transfer utp_rel.unrest_ouvar)
  also have "... = (II\<^sub>r \<triangleleft> $wait \<triangleright> (P ;; Q))"
    by simp
  also have "... = R3c(P ;; Q)"
    by (simp add: R3c_def)
  finally show ?thesis
    by (simp add: Healthy_def') 
qed

lemma R3c_cases: "R3c(P) = ((II \<triangleleft> $ok \<triangleright> R1(true)) \<triangleleft> $wait \<triangleright> P)"
  by (rel_auto)

lemma R3c_subst_wait: "R3c(P) = R3c(P \<^sub>f)"
  by (metis R3c_def cond_var_subst_right wait_vwb_lens)

lemma R3h_subst_wait: "R3h(P) = R3h(P \<^sub>f)"
  by (metis R3h_def cond_var_subst_right wait_vwb_lens)

lemma R1_R3_commute: "R1(R3(P)) = R3(R1(P))"
  by rel_auto

lemma R1_R3c_commute: "R1(R3c(P)) = R3c(R1(P))"
  by rel_auto

lemma R1_R3h_commute: "R1(R3h(P)) = R3h(R1(P))"
  by rel_auto

lemma R2_R3_commute: "R2(R3(P)) = R3(R2(P))"
  apply (rel_auto)
  using minus_zero_eq apply blast+
done

lemma R2_R3c_commute: "R2(R3c(P)) = R3c(R2(P))"
  apply (rel_auto)
  using minus_zero_eq apply blast+
done

lemma R2_R3h_commute: "R2(R3h(P)) = R3h(R2(P))"
  apply (rel_auto)
  using minus_zero_eq apply blast+
done

lemma R2c_R3c_commute: "R2c(R3c(P)) = R3c(R2c(P))"
  by (simp add: R3c_def R2c_condr R2c_wait R2c_skip_rea)

lemma R2c_ex_st': "R2c(\<exists> $st \<bullet> P) = (\<exists> $st \<bullet> R2c(P))"
  by (rel_auto)

lemma R2c_R3h_commute: "R2c(R3h(P)) = R3h(R2c(P))"
  by (simp add: R3h_def R2c_condr R2c_wait R2c_ex_st' R2c_skip_rea)

lemma R1_H1_R3c_commute:
  "R1(H1(R3c(P))) = R3c(R1(H1(P)))"
  by rel_auto

lemma R1_H1_R3h_commute:
  "R1(H1(R3h(P))) = R3h(R1(H1(P)))"
  by rel_auto

lemma R3c_H2_commute: "R3c(H2(P)) = H2(R3c(P))"
  by (simp add: H2_split R3c_def usubst, rel_auto)

lemma R3h_H2_commute: "R3h(H2(P)) = H2(R3h(P))"
  by (simp add: H2_split R3h_def usubst, rel_auto)

lemma R3c_idem: "R3c(R3c(P)) = R3c(P)"
  by rel_auto

lemma R3c_Idempotent: "Idempotent R3c"
  using Idempotent_def R3c_idem by blast

lemma R3c_mono: "P \<sqsubseteq> Q \<Longrightarrow> R3c(P) \<sqsubseteq> R3c(Q)"
  by rel_auto

lemma R3c_Monotonic: "Monotonic R3c"
  by (simp add: Monotonic_def R3c_mono)

lemma R3h_idem: "R3h(R3h(P)) = R3h(P)"
  by rel_auto

lemma R3h_Idempotent: "Idempotent R3h"
  using Idempotent_def R3h_idem by blast

lemma R3h_mono: "P \<sqsubseteq> Q \<Longrightarrow> R3h(P) \<sqsubseteq> R3h(Q)"
  by rel_auto

lemma R3h_Monotonic: "Monotonic R3h"
  by (simp add: Monotonic_def R3h_mono)

lemma R3c_conj: "R3c(P \<and> Q) = (R3c(P) \<and> R3c(Q))"
  by (rel_auto)

lemma R3c_disj: "R3c(P \<or> Q) = (R3c(P) \<or> R3c(Q))"
  by rel_auto

lemma R3c_USUP:
  assumes "A \<noteq> {}"
  shows "R3c(\<Sqinter> i \<in> A \<bullet> P(i)) = (\<Sqinter> i \<in> A \<bullet> R3c(P(i)))"
  using assms by (rel_auto)

lemma R3c_UINF:
  assumes "A \<noteq> {}"
  shows "R3c(\<Squnion> i \<in> A \<bullet> P(i)) = (\<Squnion> i \<in> A \<bullet> R3c(P(i)))"
  using assms by (rel_auto)

lemma R3h_conj: "R3h(P \<and> Q) = (R3h(P) \<and> R3h(Q))"
  by (rel_auto)

lemma R3h_disj: "R3h(P \<or> Q) = (R3h(P) \<or> R3h(Q))"
  by rel_auto

lemma R3h_USUP:
  assumes "A \<noteq> {}"
  shows "R3h(\<Sqinter> i \<in> A \<bullet> P(i)) = (\<Sqinter> i \<in> A \<bullet> R3h(P(i)))"
  using assms by (rel_auto)

lemma R3h_UINF:
  assumes "A \<noteq> {}"
  shows "R3h(\<Squnion> i \<in> A \<bullet> P(i)) = (\<Squnion> i \<in> A \<bullet> R3h(P(i)))"
  using assms by (rel_auto)

lemma R3c_refines_R3h: "R3h(P) \<sqsubseteq> R3c(P)"
  by (rel_auto)

lemma R3c_absorbs_R3h: "R3c(R3h(P)) = R3c(P)"
  by (rel_auto)

lemma R3h_absorbs_R3c: "R3h(R3c(P)) = R3h(P)"
  by (rel_auto)

lemma R1_skip_rea3: "R1(II\<^sub>R) = II\<^sub>R"
  by (rel_auto)

subsection {* RH laws *}

definition RH_def [upred_defs]: "RH(P) = R1(R2s(R3c(P)))"
definition RHS_def [upred_defs]: "RHS(P) = R1(R2s(R3h(P)))"

notation RH ("\<^bold>R")
notation RHS ("\<^bold>R\<^sub>s")

definition reactive_sup :: "_ set \<Rightarrow> _" ("\<Sqinter>\<^sub>r") where
"\<Sqinter>\<^sub>r A = (if (A = {}) then \<^bold>R(false) else \<Sqinter> A)"

definition reactive_inf :: "_ set \<Rightarrow> _" ("\<Squnion>\<^sub>r") where
"\<Squnion>\<^sub>r A = (if (A = {}) then \<^bold>R(true) else \<Squnion> A)"

lemma RH_alt_def:
  "\<^bold>R(P) = R1(R2(R3c(P)))"
  by (simp add: R1_idem R2_def RH_def)

lemma RH_alt_def':
  "\<^bold>R(P) = R2(R3c(P))"
  by (simp add: R2_def RH_def)

lemma RH_alt_def'':
  "\<^bold>R(P) = R1(R2c(R3c(P)))"
  by (simp add: R1_R2s_R2c RH_def)

lemma RHS_alt_def:
  "\<^bold>R\<^sub>s(P) = R1(R2c(R3h(P)))"
  by (simp add: RHS_def R1_R2s_R2c)  

lemma RH_idem:
  "\<^bold>R(\<^bold>R(P)) = \<^bold>R(P)"
  by (metis R2_R3c_commute R2_def R2_idem R3c_idem RH_def)

lemma RH_Idempotent: "Idempotent \<^bold>R"
  by (simp add: Idempotent_def RH_idem)

lemma RH_monotone:
  "P \<sqsubseteq> Q \<Longrightarrow> \<^bold>R(P) \<sqsubseteq> \<^bold>R(Q)"
  by rel_auto

lemma RHS_idem:
  "\<^bold>R\<^sub>s(\<^bold>R\<^sub>s(P)) = \<^bold>R\<^sub>s(P)"
  by (metis (no_types, hide_lams) R2_R3h_commute R2_def R2_idem R3h_idem RHS_def)
  
lemma RHS_Idempotent: "Idempotent \<^bold>R\<^sub>s"
  by (simp add: Idempotent_def RHS_idem)

lemma RHS_monotone:
  "P \<sqsubseteq> Q \<Longrightarrow> \<^bold>R\<^sub>s(P) \<sqsubseteq> \<^bold>R\<^sub>s(Q)"
  by rel_auto

lemma RH_disj: "\<^bold>R(P \<or> Q) = (\<^bold>R(P) \<or> \<^bold>R(Q))"
  by (simp add: RH_def R3c_disj R2s_disj R1_disj)

lemma RH_USUP:
  assumes "A \<noteq> {}"
  shows "\<^bold>R(\<Sqinter> i \<in> A \<bullet> P(i)) = (\<Sqinter> i \<in> A \<bullet> \<^bold>R(P(i)))"
  using assms by (rel_auto)

lemma RH_UINF:
  assumes "A \<noteq> {}"
  shows "\<^bold>R(\<Squnion> i \<in> A \<bullet> P(i)) = (\<Squnion> i \<in> A \<bullet> \<^bold>R(P(i)))"
  using assms by (rel_auto)

lemma RH_intro:
  "\<lbrakk> P is R1; P is R2; P is R3c \<rbrakk> \<Longrightarrow> P is \<^bold>R"
  by (simp add: Healthy_def' R2_def RH_def)

lemma R1_true_left_zero_R: "(R1(true) ;; \<^bold>R(P)) = R1(true)"
  by (rel_auto)

lemma RH_seq_closure:
  assumes "P is \<^bold>R" "Q is \<^bold>R"
  shows "(P ;; Q) is \<^bold>R"
proof (rule RH_intro)
  show "(P ;; Q) is R1"
    by (metis Healthy_def' R1_seqr_closure R2_def RH_alt_def RH_def assms(1) assms(2))
  show "(P ;; Q) is R2"
    by (metis Healthy_def' R2_def R2_idem R2_seqr_closure RH_def assms(1) assms(2))
  show "(P ;; Q) is R3c"
    by (metis Healthy_def' R2_R3c_commute R2_def R3c_idem R3c_seq_closure RH_alt_def RH_def assms(1) assms(2))
qed

lemma RH_R2c_def: "\<^bold>R(P) = R1(R2c(R3c(P)))"
  by (rel_auto)

lemma RHS_R2c_def: "\<^bold>R\<^sub>s(P) = R1(R2c(R3h(P)))"
  by (rel_auto)

lemma RH_absorbs_R2c: "\<^bold>R(R2c(P)) = \<^bold>R(P)"
  by (metis R1_R2_commute R1_R2c_is_R2 R1_R3c_commute R2_R3c_commute R2_idem RH_alt_def RH_alt_def')

lemma RH_subst_wait: "\<^bold>R(P \<^sub>f) = \<^bold>R(P)"
  by (metis R3c_subst_wait RH_alt_def')

lemma RH_false: "\<^bold>R(false) = ($wait \<and> II\<^sub>r)"
  by (rel_auto, metis minus_zero_eq)

lemma RH_true: "\<^bold>R(true) = (II\<^sub>r \<triangleleft> $wait \<triangleright> $tr \<le>\<^sub>u $tr\<acute>)"
  by (rel_auto, metis minus_zero_eq)

lemma RH_false_top:
  "\<^bold>R(P) \<sqsubseteq> \<^bold>R(false)"
  by (simp add: RH_monotone)

lemma RH_false_bottom:
  "\<^bold>R(true) \<sqsubseteq> \<^bold>R(P)"
  by (simp add: RH_monotone)

subsection {* UTP theories *}

typedecl REA
abbreviation "REA \<equiv> UTHY(REA, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp)"

typedecl SREA
abbreviation "SREA \<equiv> UTHY(SREA, ('s, 't::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rsp)"

overloading
  rea_hcond == "utp_hcond :: (REA, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp) uthy \<Rightarrow> (('t,'\<alpha>) alphabet_rp \<times> ('t,'\<alpha>) alphabet_rp) Healthiness_condition"
  srea_hcond == "utp_hcond :: (SREA, ('s,'t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rsp) uthy \<Rightarrow> (('s,'t,'\<alpha>) alphabet_rsp \<times> ('s,'t,'\<alpha>) alphabet_rsp) Healthiness_condition"

begin
  definition rea_hcond :: "(REA, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp) uthy \<Rightarrow> (('t,'\<alpha>) alphabet_rp \<times> ('t,'\<alpha>) alphabet_rp) Healthiness_condition" where
  [upred_defs]: "rea_hcond t = \<^bold>R"

  definition srea_hcond :: "(SREA, ('s,'t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rsp) uthy \<Rightarrow> (('s,'t,'\<alpha>) alphabet_rsp \<times> ('s,'t,'\<alpha>) alphabet_rsp) Healthiness_condition" where
  [upred_defs]: "srea_hcond t = \<^bold>R\<^sub>s"

end

interpretation rea_utp_theory: utp_theory "UTHY(REA, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp)"
  by (simp add: rea_hcond_def utp_theory_def RH_idem)

interpretation rea_utp_theory_mono: utp_theory_mono "UTHY(REA, ('t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rp)"
  by (unfold_locales, simp add: Monotonic_def RH_monotone rea_hcond_def)

lemma rea_top: "\<^bold>\<top>\<^bsub>REA\<^esub> = ($wait \<and> II\<^sub>r)"
proof -
  have "\<^bold>\<top>\<^bsub>REA\<^esub> = \<^bold>R(false)"
    by (simp add: rea_utp_theory_mono.healthy_top, simp add: rea_hcond_def)
  also have "... = ($wait \<and> II\<^sub>r)"
    by (rel_auto, metis minus_zero_eq)
  finally show ?thesis .
qed

lemma rea_bottom: "\<^bold>\<bottom>\<^bsub>REA\<^esub> = R1($wait \<Rightarrow> II\<^sub>r)"
proof -
  have "\<^bold>\<bottom>\<^bsub>REA\<^esub> = \<^bold>R(true)"
    by (simp add: rea_utp_theory_mono.healthy_bottom, simp add: rea_hcond_def)
  also have "... = R1($wait \<Rightarrow> II\<^sub>r)"
    by (rel_auto, metis minus_zero_eq)
  finally show ?thesis .
qed

interpretation srea_utp_theory: utp_theory "UTHY(SREA, ('s,'t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rsp)"
  by (simp add: srea_hcond_def utp_theory_def RHS_idem)

interpretation srea_utp_theory_mono: utp_theory_mono "UTHY(SREA, ('s,'t::ordered_cancel_monoid_diff,'\<alpha>) alphabet_rsp)"
  by (unfold_locales, simp add: Monotonic_def RHS_monotone srea_hcond_def)

interpretation rea_srea_bijection:
  galois_bijection "REA \<leftarrow>\<langle>R3c,R3h\<rangle>\<rightarrow> SREA"
proof (unfold_locales, simp_all add: rea_hcond_def srea_hcond_def)
  show "R3c \<in> \<lbrakk>\<^bold>R\<^sub>s\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>R\<rbrakk>\<^sub>H"
    by (simp add: Pi_iff Healthy_def RH_def R3c_idem RHS_def)
       (metis R1_R3c_commute R2_R1_form R2_R3c_commute R3c_absorbs_R3h)
  show "R3h \<in> \<lbrakk>\<^bold>R\<rbrakk>\<^sub>H \<rightarrow> \<lbrakk>\<^bold>R\<^sub>s\<rbrakk>\<^sub>H"
    by (simp add: Pi_iff Healthy_def RH_def R3h_idem RHS_def)
       (metis R1_R3h_commute R2_R1_form R2_R3h_commute R3h_absorbs_R3c)
  show "isotone (utp_order \<^bold>R\<^sub>s) (utp_order \<^bold>R) R3c"
    by (simp add: R3c_Monotonic isotone_utp_orderI)
  show "isotone (utp_order \<^bold>R) (utp_order \<^bold>R\<^sub>s) R3h"
    by (simp add: R3h_Monotonic isotone_utp_orderI)
  fix P :: "('s, 't::ordered_cancel_monoid_diff, '\<alpha>) hrelation_rsp"
  assume "P is \<^bold>R\<^sub>s"
  thus "R3h (R3c P) = P"
    by (metis Healthy_if R2_R3h_commute R2_def R3h_absorbs_R3c R3h_idem RHS_def)    
next
  fix Q :: "('s, 't::ordered_cancel_monoid_diff, '\<alpha>) hrelation_rsp"
  assume "Q is \<^bold>R"
  thus "R3c (R3h Q) = Q"
  by (metis Healthy_if R2_R3c_commute R3c_absorbs_R3h R3h_absorbs_R3c RH_alt_def')
qed

(*
interpretation rea_srea_retract:
  retract "(ex (in_var st) \<circ> R3c) \<Leftarrow>\<langle>ex (in_var st) \<circ> R3c,R3h\<rangle>\<Rightarrow> R3h"
proof -
  have "retract ((ex (in_var st) \<circ> R3c) \<Leftarrow>\<langle>ex (in_var st),R3c\<rangle>\<Rightarrow> R3c)"
    apply (rule ex_retract, simp_all add: R3c_Idempotent fun_eq_iff)
    apply (rel_auto)
*)

subsection {* Reactive parallel-by-merge *}

text {* We show closure of parallel by merge under the reactive healthiness conditions by means
  of suitable restrictions on the merge predicate. We first define healthiness conditions
  for R1 and R2 merge predicates. *}

definition [upred_defs]: "R1m(M) = (M \<and> $tr\<^sub>< \<le>\<^sub>u $tr\<acute>)"

definition [upred_defs]: "R1m'(M) = (M \<and> $tr\<^sub>< \<le>\<^sub>u $tr\<acute> \<and> $tr\<^sub>< \<le>\<^sub>u $0-tr \<and> $tr\<^sub>< \<le>\<^sub>u $1-tr)"

text {* A merge predicate can access the history through $tr$, as usual, but also through $0.tr$ and
  $1.tr$. Thus we have to remove the latter two histories as well to satisfy R2 for the overall
  construction. *}

definition [upred_defs]: "R2m(M) = R1m(M\<lbrakk>0,$tr\<acute> - $tr\<^sub><,$0-tr - $tr\<^sub><,$1-tr - $tr\<^sub></$tr\<^sub><,$tr\<acute>,$0-tr,$1-tr\<rbrakk>)"

definition [upred_defs]: "R2m'(M) = R1m'(M\<lbrakk>0,$tr\<acute> - $tr\<^sub><,$0-tr - $tr\<^sub><,$1-tr - $tr\<^sub></$tr\<^sub><,$tr\<acute>,$0-tr,$1-tr\<rbrakk>)"

lemma R2m'_form: 
  "R2m'(M) = 
  (\<^bold>\<exists> tt, tt\<^sub>0, tt\<^sub>1 \<bullet> M\<lbrakk>0,\<guillemotleft>tt\<guillemotright>,\<guillemotleft>tt\<^sub>0\<guillemotright>,\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<^sub><,$tr\<acute>,$0-tr,$1-tr\<rbrakk> 
                  \<and> $tr\<acute> =\<^sub>u $tr\<^sub>< + \<guillemotleft>tt\<guillemotright> 
                  \<and> $0-tr =\<^sub>u $tr\<^sub>< + \<guillemotleft>tt\<^sub>0\<guillemotright> 
                  \<and> $1-tr =\<^sub>u $tr\<^sub>< + \<guillemotleft>tt\<^sub>1\<guillemotright>)"
  by (rel_auto, metis diff_add_cancel_left')

lemma R1_par_by_merge:
  "M is R1m \<Longrightarrow> (P \<parallel>\<^bsub>M\<^esub> Q) is R1"
  by (rel_blast)

lemma R2_par_by_merge:
  assumes "P is R2" "Q is R2" "M is R2m"
  shows "(P \<parallel>\<^bsub>M\<^esub> Q) is R2"
proof -
  have "(P \<parallel>\<^bsub>M\<^esub> Q) = (P \<parallel>\<^bsub>R2m(M)\<^esub> Q)"
    by (metis Healthy_def' assms(3))
  also have "... = (R2(P) \<parallel>\<^bsub>R2m(M)\<^esub> R2(Q))"
    using assms by (simp add: Healthy_def')
  also have "... = (R2(P) \<parallel>\<^bsub>R2m'(M)\<^esub> R2(Q))"
    by (rel_blast)
  also have "... = (P \<parallel>\<^bsub>R2m'(M)\<^esub> Q)"
    using assms by (simp add: Healthy_def')
  also have "... = ((P \<parallel>\<^sub>s Q) ;;
                   (\<^bold>\<exists> tt, tt\<^sub>0, tt\<^sub>1 \<bullet> M\<lbrakk>0,\<guillemotleft>tt\<guillemotright>,\<guillemotleft>tt\<^sub>0\<guillemotright>,\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<^sub><,$tr\<acute>,$0-tr,$1-tr\<rbrakk> 
                                     \<and> $tr\<acute> =\<^sub>u $tr\<^sub>< + \<guillemotleft>tt\<guillemotright> 
                                     \<and> $0-tr =\<^sub>u $tr\<^sub>< + \<guillemotleft>tt\<^sub>0\<guillemotright> 
                                     \<and> $1-tr =\<^sub>u $tr\<^sub>< + \<guillemotleft>tt\<^sub>1\<guillemotright>))"
    by (simp add: par_by_merge_def R2m'_form)
  also have "... = (\<^bold>\<exists> tt, tt\<^sub>0, tt\<^sub>1 \<bullet> ((P \<parallel>\<^sub>s Q) ;; (M\<lbrakk>0,\<guillemotleft>tt\<guillemotright>,\<guillemotleft>tt\<^sub>0\<guillemotright>,\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<^sub><,$tr\<acute>,$0-tr,$1-tr\<rbrakk> 
                                                  \<and> $tr\<acute> =\<^sub>u $tr\<^sub>< + \<guillemotleft>tt\<guillemotright> 
                                                  \<and> $0-tr =\<^sub>u $tr\<^sub>< + \<guillemotleft>tt\<^sub>0\<guillemotright> 
                                                  \<and> $1-tr =\<^sub>u $tr\<^sub>< + \<guillemotleft>tt\<^sub>1\<guillemotright>)))"
    by (rel_blast)
  also have "... = (\<^bold>\<exists> tt, tt\<^sub>0, tt\<^sub>1 \<bullet> ((P \<parallel>\<^sub>s Q) \<and> $0-tr\<acute> =\<^sub>u $tr\<^sub><\<acute> + \<guillemotleft>tt\<^sub>0\<guillemotright> \<and> $1-tr\<acute> =\<^sub>u $tr\<^sub><\<acute> + \<guillemotleft>tt\<^sub>1\<guillemotright> ;; 
                                      (M\<lbrakk>0,\<guillemotleft>tt\<guillemotright>,\<guillemotleft>tt\<^sub>0\<guillemotright>,\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<^sub><,$tr\<acute>,$0-tr,$1-tr\<rbrakk> \<and> $tr\<acute> =\<^sub>u $tr\<^sub>< + \<guillemotleft>tt\<guillemotright>)))"
    by (rel_blast)
  also have "... = (\<^bold>\<exists> tt, tt\<^sub>0, tt\<^sub>1 \<bullet> ((P \<parallel>\<^sub>s Q) \<and> $0-tr\<acute> =\<^sub>u $tr\<^sub><\<acute> + \<guillemotleft>tt\<^sub>0\<guillemotright> \<and> $1-tr\<acute> =\<^sub>u $tr\<^sub><\<acute> + \<guillemotleft>tt\<^sub>1\<guillemotright> ;; 
                                      (M\<lbrakk>0,\<guillemotleft>tt\<guillemotright>,\<guillemotleft>tt\<^sub>0\<guillemotright>,\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<^sub><,$tr\<acute>,$0-tr,$1-tr\<rbrakk>)) \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<guillemotright>)"
    by (rel_blast)
  also have "... = (\<^bold>\<exists> tt, tt\<^sub>0, tt\<^sub>1 \<bullet> (((P \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>0\<guillemotright>) \<parallel>\<^sub>s (Q \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright>)) ;; 
                                      (M\<lbrakk>0,\<guillemotleft>tt\<guillemotright>,\<guillemotleft>tt\<^sub>0\<guillemotright>,\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<^sub><,$tr\<acute>,$0-tr,$1-tr\<rbrakk>)) \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<guillemotright>)"
    by (rel_blast)
  also have "... = (\<^bold>\<exists> tt, tt\<^sub>0, tt\<^sub>1 \<bullet> (((R2(P) \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>0\<guillemotright>) \<parallel>\<^sub>s (R2(Q) \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright>)) ;; 
                                      (M\<lbrakk>0,\<guillemotleft>tt\<guillemotright>,\<guillemotleft>tt\<^sub>0\<guillemotright>,\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<^sub><,$tr\<acute>,$0-tr,$1-tr\<rbrakk>)) \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<guillemotright>)"
    using assms(1-2) by (simp add: Healthy_def')                                      
  also have "... = (\<^bold>\<exists> tt, tt\<^sub>0, tt\<^sub>1 \<bullet> ((   ((\<^bold>\<exists> tt\<^sub>0' \<bullet> P\<lbrakk>0,\<guillemotleft>tt\<^sub>0'\<guillemotright>/$tr,$tr\<acute>\<rbrakk> \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>0'\<guillemotright>) \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>0\<guillemotright>) 
                                       \<parallel>\<^sub>s ((\<^bold>\<exists> tt\<^sub>1' \<bullet> Q\<lbrakk>0,\<guillemotleft>tt\<^sub>1'\<guillemotright>/$tr,$tr\<acute>\<rbrakk> \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1'\<guillemotright>) \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright>)) ;; 
                                      (M\<lbrakk>0,\<guillemotleft>tt\<guillemotright>,\<guillemotleft>tt\<^sub>0\<guillemotright>,\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<^sub><,$tr\<acute>,$0-tr,$1-tr\<rbrakk>)) \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<guillemotright>)"
    by (simp add: R2_form usubst)
  also have "... = (\<^bold>\<exists> tt, tt\<^sub>0, tt\<^sub>1 \<bullet> ((   (P\<lbrakk>0,\<guillemotleft>tt\<^sub>0\<guillemotright>/$tr,$tr\<acute>\<rbrakk>  \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>0\<guillemotright>) 
                                       \<parallel>\<^sub>s (Q\<lbrakk>0,\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr,$tr\<acute>\<rbrakk> \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<^sub>1\<guillemotright>)) ;; 
                                      (M\<lbrakk>0,\<guillemotleft>tt\<guillemotright>,\<guillemotleft>tt\<^sub>0\<guillemotright>,\<guillemotleft>tt\<^sub>1\<guillemotright>/$tr\<^sub><,$tr\<acute>,$0-tr,$1-tr\<rbrakk>)) \<and> $tr\<acute> =\<^sub>u $tr + \<guillemotleft>tt\<guillemotright>)"
    by (rel_auto, metis left_cancel_monoid_class.add_left_imp_eq, blast)
  also have "... = R2(P \<parallel>\<^bsub>M\<^esub> Q)"
    by (rel_auto, blast, metis diff_add_cancel_left')
  finally show ?thesis
    by (simp add: Healthy_def)
qed

text {* For R3, we can't easily define an idempotent healthiness function of mege predicates. Thus
  we define some units and anhilators instead. Each of these defines the behaviour of an indexed 
  parallel system of predicates to be merged. *}

definition [upred_defs]: "skip\<^sub>m = ($0-\<Sigma>\<acute> =\<^sub>u $\<Sigma> \<and> $1-\<Sigma>\<acute> =\<^sub>u $\<Sigma> \<and> $\<Sigma>\<^sub><\<acute> =\<^sub>u $\<Sigma>)"

text {* @{term "skip\<^sub>m"} is the system which does nothing to the variables in both predicates. A merge
  predicate which is R3 must yield @{term II} when composed with it. *}

lemma R3_par_by_merge:
  assumes 
    "P is R3" "Q is R3" "(skip\<^sub>m ;; M) = II"
  shows "(P \<parallel>\<^bsub>M\<^esub> Q) is R3"
proof -
  have "(P \<parallel>\<^bsub>M\<^esub> Q) = ((P \<parallel>\<^bsub>M\<^esub> Q)\<lbrakk>true/$wait\<rbrakk> \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (metis cond_L6 cond_var_split in_var_uvar wait_vwb_lens)
  also have "... = ((P\<lbrakk>true/$wait\<rbrakk> \<parallel>\<^bsub>M\<^esub> Q\<lbrakk>true/$wait\<rbrakk>)\<lbrakk>true/$wait\<rbrakk> \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (rel_auto)
  also have "... = ((P\<lbrakk>true/$wait\<rbrakk> \<parallel>\<^bsub>M\<^esub> Q\<lbrakk>true/$wait\<rbrakk>) \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (metis cond_var_subst_left wait_vwb_lens)
  also have "... = (((II \<triangleleft> $wait \<triangleright> P)\<lbrakk>true/$wait\<rbrakk> \<parallel>\<^bsub>M\<^esub> (II \<triangleleft> $wait \<triangleright> Q)\<lbrakk>true/$wait\<rbrakk>) \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (metis Healthy_if R3_def assms(1) assms(2))
  also have "... = ((II\<lbrakk>true/$wait\<rbrakk> \<parallel>\<^bsub>M\<^esub> II\<lbrakk>true/$wait\<rbrakk>) \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (subst_tac)
  also have "... = ((II \<parallel>\<^bsub>M\<^esub> II) \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (rel_auto)
  also have "... = ((skip\<^sub>m ;; M) \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (rel_auto)
  also have "... = (II \<triangleleft> $wait \<triangleright> (P \<parallel>\<^bsub>M\<^esub> Q))"
    by (simp add: assms(3))
  also have "... = R3(P \<parallel>\<^bsub>M\<^esub> Q)"
    by (simp add: R3_def)
  finally show ?thesis
    by (simp add: Healthy_def')
qed

end
