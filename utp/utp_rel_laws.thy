section {* Relational Calculus Laws *}

theory utp_rel_laws
  imports 
    utp_rel
    utp_recursion
begin

subsection {* Conditional Laws *}
  
lemma comp_cond_left_distr:
  "((P \<triangleleft> b \<triangleright>\<^sub>r Q) ;; R) = ((P ;; R) \<triangleleft> b \<triangleright>\<^sub>r (Q ;; R))"
  by (rel_auto)

lemma cond_seq_left_distr:
  "out\<alpha> \<sharp> b \<Longrightarrow> ((P \<triangleleft> b \<triangleright> Q) ;; R) = ((P ;; R) \<triangleleft> b \<triangleright> (Q ;; R))"
  by (rel_auto)

lemma cond_seq_right_distr:
  "in\<alpha> \<sharp> b \<Longrightarrow> (P ;; (Q \<triangleleft> b \<triangleright> R)) = ((P ;; Q) \<triangleleft> b \<triangleright> (P ;; R))"
  by (rel_auto)

lemma cond_mono:
  "\<lbrakk> P\<^sub>1 \<sqsubseteq> P\<^sub>2; Q\<^sub>1 \<sqsubseteq> Q\<^sub>2 \<rbrakk> \<Longrightarrow> (P\<^sub>1 \<triangleleft> b \<triangleright> Q\<^sub>1) \<sqsubseteq> (P\<^sub>2 \<triangleleft> b \<triangleright> Q\<^sub>2)"
  by (rel_auto)

lemma cond_monotonic:
  "\<lbrakk> mono P; mono Q \<rbrakk> \<Longrightarrow> mono (\<lambda> X. P X \<triangleleft> b \<triangleright> Q X)"
  by (simp add: mono_def, rel_blast)

subsection {* Precondition and Postcondition Laws *}
  
theorem precond_equiv:
  "P = (P ;; true) \<longleftrightarrow> (out\<alpha> \<sharp> P)"
  by (rel_auto)

theorem postcond_equiv:
  "P = (true ;; P) \<longleftrightarrow> (in\<alpha> \<sharp> P)"
  by (rel_auto)

lemma precond_right_unit: "out\<alpha> \<sharp> p \<Longrightarrow> (p ;; true) = p"
  by (metis precond_equiv)

lemma postcond_left_unit: "in\<alpha> \<sharp> p \<Longrightarrow> (true ;; p) = p"
  by (metis postcond_equiv)

theorem precond_left_zero:
  assumes "out\<alpha> \<sharp> p" "p \<noteq> false"
  shows "(true ;; p) = true"
  using assms by (rel_auto)

theorem feasibile_iff_true_right_zero:
  "P ;; true = true \<longleftrightarrow> `\<exists> out\<alpha> \<bullet> P`"
  by (rel_auto)
    
subsection {* Sequential Composition Laws *}
    
lemma seqr_assoc: "(P ;; Q) ;; R = P ;; (Q ;; R)"
  by (rel_auto)

lemma seqr_left_unit [simp]:
  "II ;; P = P"
  by (rel_auto)

lemma seqr_right_unit [simp]:
  "P ;; II = P"
  by (rel_auto)

lemma seqr_left_zero [simp]:
  "false ;; P = false"
  by pred_auto

lemma seqr_right_zero [simp]:
  "P ;; false = false"
  by pred_auto

lemma impl_seqr_mono: "\<lbrakk> `P \<Rightarrow> Q`; `R \<Rightarrow> S` \<rbrakk> \<Longrightarrow> `(P ;; R) \<Rightarrow> (Q ;; S)`"
  by (pred_blast)

lemma seqr_mono:
  "\<lbrakk> P\<^sub>1 \<sqsubseteq> P\<^sub>2; Q\<^sub>1 \<sqsubseteq> Q\<^sub>2 \<rbrakk> \<Longrightarrow> (P\<^sub>1 ;; Q\<^sub>1) \<sqsubseteq> (P\<^sub>2 ;; Q\<^sub>2)"
  by (rel_blast)

lemma seqr_monotonic:
  "\<lbrakk> mono P; mono Q \<rbrakk> \<Longrightarrow> mono (\<lambda> X. P X ;; Q X)"
  by (simp add: mono_def, rel_blast)

lemma seqr_exists_left:
  "((\<exists> $x \<bullet> P) ;; Q) = (\<exists> $x \<bullet> (P ;; Q))"
  by (rel_auto)

lemma seqr_exists_right:
  "(P ;; (\<exists> $x\<acute> \<bullet> Q)) = (\<exists> $x\<acute> \<bullet> (P ;; Q))"
  by (rel_auto)

lemma seqr_or_distl:
  "((P \<or> Q) ;; R) = ((P ;; R) \<or> (Q ;; R))"
  by (rel_auto)

lemma seqr_or_distr:
  "(P ;; (Q \<or> R)) = ((P ;; Q) \<or> (P ;; R))"
  by (rel_auto)

lemma seqr_and_distr_ufunc:
  "ufunctional P \<Longrightarrow> (P ;; (Q \<and> R)) = ((P ;; Q) \<and> (P ;; R))"
  by (rel_auto)

lemma seqr_and_distl_uinj:
  "uinj R \<Longrightarrow> ((P \<and> Q) ;; R) = ((P ;; R) \<and> (Q ;; R))"
  by (rel_auto)

lemma seqr_unfold:
  "(P ;; Q) = (\<^bold>\<exists> v \<bullet> P\<lbrakk>\<guillemotleft>v\<guillemotright>/$\<^bold>v\<acute>\<rbrakk> \<and> Q\<lbrakk>\<guillemotleft>v\<guillemotright>/$\<^bold>v\<rbrakk>)"
  by (rel_auto)

lemma seqr_middle:
  assumes "vwb_lens x"
  shows "(P ;; Q) = (\<^bold>\<exists> v \<bullet> P\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<acute>\<rbrakk> ;; Q\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<rbrakk>)"
  using assms
  apply (rel_auto robust)
  apply (rename_tac xa P Q a b y)
  apply (rule_tac x="get\<^bsub>xa\<^esub> y" in exI)
  apply (rule_tac x="y" in exI)
  apply (simp)
done

lemma seqr_left_one_point:
  assumes "vwb_lens x"
  shows "((P \<and> $x\<acute> =\<^sub>u \<guillemotleft>v\<guillemotright>) ;; Q) = (P\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<acute>\<rbrakk> ;; Q\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<rbrakk>)"
  using assms
  by (rel_auto, metis vwb_lens_wb wb_lens.get_put)

lemma seqr_right_one_point:
  assumes "vwb_lens x"
  shows "(P ;; ($x =\<^sub>u \<guillemotleft>v\<guillemotright> \<and> Q)) = (P\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<acute>\<rbrakk> ;; Q\<lbrakk>\<guillemotleft>v\<guillemotright>/$x\<rbrakk>)"
  using assms
  by (rel_auto, metis vwb_lens_wb wb_lens.get_put)

lemma seqr_left_one_point_true:
  assumes "vwb_lens x"
  shows "((P \<and> $x\<acute>) ;; Q) = (P\<lbrakk>true/$x\<acute>\<rbrakk> ;; Q\<lbrakk>true/$x\<rbrakk>)"
  by (metis assms seqr_left_one_point true_alt_def upred_eq_true)

lemma seqr_left_one_point_false:
  assumes "vwb_lens x"
  shows "((P \<and> \<not>$x\<acute>) ;; Q) = (P\<lbrakk>false/$x\<acute>\<rbrakk> ;; Q\<lbrakk>false/$x\<rbrakk>)"
  by (metis assms false_alt_def seqr_left_one_point upred_eq_false)

lemma seqr_right_one_point_true:
  assumes "vwb_lens x"
  shows "(P ;; ($x \<and> Q)) = (P\<lbrakk>true/$x\<acute>\<rbrakk> ;; Q\<lbrakk>true/$x\<rbrakk>)"
  by (metis assms seqr_right_one_point true_alt_def upred_eq_true)

lemma seqr_right_one_point_false:
  assumes "vwb_lens x"
  shows "(P ;; (\<not>$x \<and> Q)) = (P\<lbrakk>false/$x\<acute>\<rbrakk> ;; Q\<lbrakk>false/$x\<rbrakk>)"
  by (metis assms false_alt_def seqr_right_one_point upred_eq_false)

lemma seqr_insert_ident_left:
  assumes "vwb_lens x" "$x\<acute> \<sharp> P" "$x \<sharp> Q"
  shows "(($x\<acute> =\<^sub>u $x \<and> P) ;; Q) = (P ;; Q)"
  using assms
  by (rel_simp, meson vwb_lens_wb wb_lens_weak weak_lens.put_get)

lemma seqr_insert_ident_right:
  assumes "vwb_lens x" "$x\<acute> \<sharp> P" "$x \<sharp> Q"
  shows "(P ;; ($x\<acute> =\<^sub>u $x \<and> Q)) = (P ;; Q)"
  using assms
  by (rel_simp, metis (no_types, hide_lams) vwb_lens_def wb_lens_def weak_lens.put_get)

lemma seq_var_ident_lift:
  assumes "vwb_lens x" "$x\<acute> \<sharp> P" "$x \<sharp> Q"
  shows "(($x\<acute> =\<^sub>u $x \<and> P) ;; ($x\<acute> =\<^sub>u $x \<and> Q)) = ($x\<acute> =\<^sub>u $x \<and> (P ;; Q))"
  using assms apply (rel_auto)
  by (metis (no_types, lifting) vwb_lens_wb wb_lens_weak weak_lens.put_get)

lemma seqr_bool_split:
  assumes "vwb_lens x"
  shows "P ;; Q = (P\<lbrakk>true/$x\<acute>\<rbrakk> ;; Q\<lbrakk>true/$x\<rbrakk> \<or> P\<lbrakk>false/$x\<acute>\<rbrakk> ;; Q\<lbrakk>false/$x\<rbrakk>)"
  using assms
  by (subst seqr_middle[of x], simp_all add: true_alt_def false_alt_def)

lemma cond_inter_var_split:
  assumes "vwb_lens x"
  shows "(P \<triangleleft> $x\<acute> \<triangleright> Q) ;; R = (P\<lbrakk>true/$x\<acute>\<rbrakk> ;; R\<lbrakk>true/$x\<rbrakk> \<or> Q\<lbrakk>false/$x\<acute>\<rbrakk> ;; R\<lbrakk>false/$x\<rbrakk>)"
proof -
  have "(P \<triangleleft> $x\<acute> \<triangleright> Q) ;; R = (($x\<acute> \<and> P) ;; R \<or> (\<not> $x\<acute> \<and> Q) ;; R)"
    by (simp add: cond_def seqr_or_distl)
  also have "... = ((P \<and> $x\<acute>) ;; R \<or> (Q \<and> \<not>$x\<acute>) ;; R)"
    by (rel_auto)
  also have "... = (P\<lbrakk>true/$x\<acute>\<rbrakk> ;; R\<lbrakk>true/$x\<rbrakk> \<or> Q\<lbrakk>false/$x\<acute>\<rbrakk> ;; R\<lbrakk>false/$x\<rbrakk>)"
    by (simp add: seqr_left_one_point_true seqr_left_one_point_false assms)
  finally show ?thesis .
qed

theorem seqr_pre_transfer: "in\<alpha> \<sharp> q \<Longrightarrow> ((P \<and> q) ;; R) = (P ;; (q\<^sup>- \<and> R))"
  by (rel_auto)

theorem seqr_pre_transfer':
  "((P \<and> \<lceil>q\<rceil>\<^sub>>) ;; R) = (P ;; (\<lceil>q\<rceil>\<^sub>< \<and> R))"
  by (rel_auto)

theorem seqr_post_out: "in\<alpha> \<sharp> r \<Longrightarrow> (P ;; (Q \<and> r)) = ((P ;; Q) \<and> r)"
  by (rel_blast)

lemma seqr_post_var_out:
  fixes x :: "(bool \<Longrightarrow> '\<alpha>)"
  shows "(P ;; (Q \<and> $x\<acute>)) = ((P ;; Q) \<and> $x\<acute>)"
  by (rel_auto)

theorem seqr_post_transfer: "out\<alpha> \<sharp> q \<Longrightarrow> (P ;; (q \<and> R)) = ((P \<and> q\<^sup>-) ;; R)"
  by (rel_auto)

lemma seqr_pre_out: "out\<alpha> \<sharp> p \<Longrightarrow> ((p \<and> Q) ;; R) = (p \<and> (Q ;; R))"
  by (rel_blast)

lemma seqr_pre_var_out:
  fixes x :: "(bool \<Longrightarrow> '\<alpha>)"
  shows "(($x \<and> P) ;; Q) = ($x \<and> (P ;; Q))"
  by (rel_auto)

lemma seqr_true_lemma:
  "(P = (\<not> ((\<not> P) ;; true))) = (P = (P ;; true))"
  by (rel_auto)

lemma seqr_to_conj: "\<lbrakk> out\<alpha> \<sharp> P; in\<alpha> \<sharp> Q \<rbrakk> \<Longrightarrow> (P ;; Q) = (P \<and> Q)"
  by (metis postcond_left_unit seqr_pre_out utp_pred_laws.inf_top.right_neutral)

lemma shEx_lift_seq_1 [uquant_lift]:
  "((\<^bold>\<exists> x \<bullet> P x) ;; Q) = (\<^bold>\<exists> x \<bullet> (P x ;; Q))"
  by pred_auto

lemma shEx_lift_seq_2 [uquant_lift]:
  "(P ;; (\<^bold>\<exists> x \<bullet> Q x)) = (\<^bold>\<exists> x \<bullet> (P ;; Q x))"
  by pred_auto
  
subsection {* Iterated Sequential Composition Laws *}
  
lemma iter_seqr_nil [simp]: "(;; i : [] \<bullet> P(i)) = II"
  by (simp add: seqr_iter_def)
    
lemma iter_seqr_cons [simp]: "(;; i : (x # xs) \<bullet> P(i)) = P(x) ;; (;; i : xs \<bullet> P(i))"
  by (simp add: seqr_iter_def)

subsection {* Quantale Laws *}

lemma seq_Sup_distl: "P ;; (\<Sqinter> A) = (\<Sqinter> Q\<in>A. P ;; Q)"
  by (transfer, auto)

lemma seq_Sup_distr: "(\<Sqinter> A) ;; Q = (\<Sqinter> P\<in>A. P ;; Q)"
  by (transfer, auto)

lemma seq_UINF_distl: "P ;; (\<Sqinter> Q\<in>A \<bullet> F(Q)) = (\<Sqinter> Q\<in>A \<bullet> P ;; F(Q))"
  by (simp add: UINF_as_Sup_collect seq_Sup_distl)

lemma seq_UINF_distl': "P ;; (\<Sqinter> Q \<bullet> F(Q)) = (\<Sqinter> Q \<bullet> P ;; F(Q))"
  by (metis UINF_mem_UNIV seq_UINF_distl)

lemma seq_UINF_distr: "(\<Sqinter> P\<in>A \<bullet> F(P)) ;; Q = (\<Sqinter> P\<in>A \<bullet> F(P) ;; Q)"
  by (simp add: UINF_as_Sup_collect seq_Sup_distr)

lemma seq_UINF_distr': "(\<Sqinter> P \<bullet> F(P)) ;; Q = (\<Sqinter> P \<bullet> F(P) ;; Q)"
  by (metis UINF_mem_UNIV seq_UINF_distr)

lemma seq_SUP_distl: "P ;; (\<Sqinter>i\<in>A. Q(i)) = (\<Sqinter>i\<in>A. P ;; Q(i))"
  by (metis image_image seq_Sup_distl)

lemma seq_SUP_distr: "(\<Sqinter>i\<in>A. P(i)) ;; Q = (\<Sqinter>i\<in>A. P(i) ;; Q)"
  by (simp add: seq_Sup_distr)

subsection {* Skip Laws *}
    
lemma cond_skip: "out\<alpha> \<sharp> b \<Longrightarrow> (b \<and> II) = (II \<and> b\<^sup>-)"
  by (rel_auto)

lemma pre_skip_post: "(\<lceil>b\<rceil>\<^sub>< \<and> II) = (II \<and> \<lceil>b\<rceil>\<^sub>>)"
  by (rel_auto)

lemma skip_var:
  fixes x :: "(bool \<Longrightarrow> '\<alpha>)"
  shows "($x \<and> II) = (II \<and> $x\<acute>)"
  by (rel_auto)

lemma skip_r_unfold:
  "vwb_lens x \<Longrightarrow> II = ($x\<acute> =\<^sub>u $x \<and> II\<restriction>\<^sub>\<alpha>x)"
  by (rel_simp, metis mwb_lens.put_put vwb_lens_mwb vwb_lens_wb wb_lens.get_put)

lemma skip_r_alpha_eq:
  "II = ($\<^bold>v\<acute> =\<^sub>u $\<^bold>v)"
  by (rel_auto)

lemma skip_ra_unfold:
  "II\<^bsub>x;y\<^esub> = ($x\<acute> =\<^sub>u $x \<and> II\<^bsub>y\<^esub>)"
  by (rel_auto)

lemma skip_res_as_ra:
  "\<lbrakk> vwb_lens y; x +\<^sub>L y \<approx>\<^sub>L 1\<^sub>L; x \<bowtie> y \<rbrakk> \<Longrightarrow> II\<restriction>\<^sub>\<alpha>x = II\<^bsub>y\<^esub>"
  apply (rel_auto)
  apply (metis (no_types, lifting) lens_indep_def)
  apply (metis vwb_lens.put_eq)
done

subsection {* Assignment Laws *}
  
lemma assigns_subst [usubst]:
  "\<lceil>\<sigma>\<rceil>\<^sub>s \<dagger> \<langle>\<rho>\<rangle>\<^sub>a = \<langle>\<rho> \<circ> \<sigma>\<rangle>\<^sub>a"
  by (rel_auto)

lemma assigns_r_comp: "(\<langle>\<sigma>\<rangle>\<^sub>a ;; P) = (\<lceil>\<sigma>\<rceil>\<^sub>s \<dagger> P)"
  by (rel_auto)

lemma assigns_r_feasible:
  "(\<langle>\<sigma>\<rangle>\<^sub>a ;; true) = true"
  by (rel_auto)

lemma assign_subst [usubst]:
  "\<lbrakk> mwb_lens x; mwb_lens y \<rbrakk> \<Longrightarrow> [$x \<mapsto>\<^sub>s \<lceil>u\<rceil>\<^sub><] \<dagger> (y := v) = (x, y := u, [x \<mapsto>\<^sub>s u] \<dagger> v)"
  by (rel_auto)
    
lemma assigns_idem: "mwb_lens x \<Longrightarrow> (x,x := u,v) = (x := v)"
  by (simp add: usubst)

lemma assigns_comp: "(\<langle>f\<rangle>\<^sub>a ;; \<langle>g\<rangle>\<^sub>a) = \<langle>g \<circ> f\<rangle>\<^sub>a"
  by (simp add: assigns_r_comp usubst)

lemma assigns_r_conv:
  "bij f \<Longrightarrow> \<langle>f\<rangle>\<^sub>a\<^sup>- = \<langle>inv f\<rangle>\<^sub>a"
  by (rel_auto, simp_all add: bij_is_inj bij_is_surj surj_f_inv_f)

lemma assign_pred_transfer:
  fixes x :: "('a \<Longrightarrow> '\<alpha>)"
  assumes "$x \<sharp> b" "out\<alpha> \<sharp> b"
  shows "(b \<and> x := v) = (x := v \<and> b\<^sup>-)"
  using assms by (rel_blast)
    
lemma assign_r_comp: "x := u ;; P = P\<lbrakk>\<lceil>u\<rceil>\<^sub></$x\<rbrakk>"
  by (simp add: assigns_r_comp usubst alpha)
    
lemma assign_test: "mwb_lens x \<Longrightarrow> (x := \<guillemotleft>u\<guillemotright> ;; x := \<guillemotleft>v\<guillemotright>) = (x := \<guillemotleft>v\<guillemotright>)"
  by (simp add: assigns_comp usubst)
    
lemma assign_twice: "\<lbrakk> mwb_lens x; x \<sharp> f \<rbrakk> \<Longrightarrow> (x := e ;; x := f) = (x := f)"
  by (simp add: assigns_comp usubst unrest)
 
lemma assign_commute:
  assumes "x \<bowtie> y" "x \<sharp> f" "y \<sharp> e"
  shows "(x := e ;; y := f) = (y := f ;; x := e)"
  using assms
  by (rel_simp, simp_all add: lens_indep_comm)

lemma assign_cond:
  fixes x :: "('a \<Longrightarrow> '\<alpha>)"
  assumes "out\<alpha> \<sharp> b"
  shows "(x := e ;; (P \<triangleleft> b \<triangleright> Q)) = ((x := e ;; P) \<triangleleft> (b\<lbrakk>\<lceil>e\<rceil>\<^sub></$x\<rbrakk>) \<triangleright> (x := e ;; Q))"
  by (rel_auto)

lemma assign_rcond:
  fixes x :: "('a \<Longrightarrow> '\<alpha>)"
  shows "(x := e ;; (P \<triangleleft> b \<triangleright>\<^sub>r Q)) = ((x := e ;; P) \<triangleleft> (b\<lbrakk>e/x\<rbrakk>) \<triangleright>\<^sub>r (x := e ;; Q))"
  by (rel_auto)

lemma assign_r_alt_def:
  fixes x :: "('a \<Longrightarrow> '\<alpha>)"
  shows "x := v = II\<lbrakk>\<lceil>v\<rceil>\<^sub></$x\<rbrakk>"
  by (rel_auto)

lemma assigns_r_ufunc: "ufunctional \<langle>f\<rangle>\<^sub>a"
  by (rel_auto)

lemma assigns_r_uinj: "inj f \<Longrightarrow> uinj \<langle>f\<rangle>\<^sub>a"
  by (rel_simp, simp add: inj_eq)
    
lemma assigns_r_swap_uinj:
  "\<lbrakk> vwb_lens x; vwb_lens y; x \<bowtie> y \<rbrakk> \<Longrightarrow> uinj ((x,y) := (&y,&x))"
  by (metis assigns_r_uinj pr_var_def swap_usubst_inj)

lemma assign_unfold:
  "vwb_lens x \<Longrightarrow> (x := v) = ($x\<acute> =\<^sub>u \<lceil>v\<rceil>\<^sub>< \<and> II\<restriction>\<^sub>\<alpha>x)"
  apply (rel_auto, auto simp add: comp_def)
  using vwb_lens.put_eq by fastforce

subsection {* Converse Laws *}

lemma convr_invol [simp]: "p\<^sup>-\<^sup>- = p"
  by pred_auto

lemma lit_convr [simp]: "\<guillemotleft>v\<guillemotright>\<^sup>- = \<guillemotleft>v\<guillemotright>"
  by pred_auto

lemma uivar_convr [simp]:
  fixes x :: "('a \<Longrightarrow> '\<alpha>)"
  shows "($x)\<^sup>- = $x\<acute>"
  by pred_auto

lemma uovar_convr [simp]:
  fixes x :: "('a \<Longrightarrow> '\<alpha>)"
  shows "($x\<acute>)\<^sup>- = $x"
  by pred_auto

lemma uop_convr [simp]: "(uop f u)\<^sup>- = uop f (u\<^sup>-)"
  by (pred_auto)

lemma bop_convr [simp]: "(bop f u v)\<^sup>- = bop f (u\<^sup>-) (v\<^sup>-)"
  by (pred_auto)

lemma eq_convr [simp]: "(p =\<^sub>u q)\<^sup>- = (p\<^sup>- =\<^sub>u q\<^sup>-)"
  by (pred_auto)

lemma not_convr [simp]: "(\<not> p)\<^sup>- = (\<not> p\<^sup>-)"
  by (pred_auto)

lemma disj_convr [simp]: "(p \<or> q)\<^sup>- = (q\<^sup>- \<or> p\<^sup>-)"
  by (pred_auto)

lemma conj_convr [simp]: "(p \<and> q)\<^sup>- = (q\<^sup>- \<and> p\<^sup>-)"
  by (pred_auto)

lemma seqr_convr [simp]: "(p ;; q)\<^sup>- = (q\<^sup>- ;; p\<^sup>-)"
  by (rel_auto)

lemma pre_convr [simp]: "\<lceil>p\<rceil>\<^sub><\<^sup>- = \<lceil>p\<rceil>\<^sub>>"
  by (rel_auto)

lemma post_convr [simp]: "\<lceil>p\<rceil>\<^sub>>\<^sup>- = \<lceil>p\<rceil>\<^sub><"
  by (rel_auto)

subsection {* Assertion and Assumption Laws *}

declare sublens_def [lens_defs del]
  
lemma assume_false: "[false]\<^sup>\<top> = false"
  by (rel_auto)
  
lemma assume_true: "[true]\<^sup>\<top> = II"
  by (rel_auto)
    
lemma assume_seq: "[b]\<^sup>\<top> ;; [c]\<^sup>\<top> = [b \<and> c]\<^sup>\<top>"
  by (rel_auto)

lemma assert_false: "{false}\<^sub>\<bottom> = true"
  by (rel_auto)

lemma assert_true: "{true}\<^sub>\<bottom> = II"
  by (rel_auto)
    
lemma assert_seq: "{b}\<^sub>\<bottom> ;; {c}\<^sub>\<bottom> = {b \<and> c}\<^sub>\<bottom>"
  by (rel_auto)

lemma frame_disj: "(x:\<lbrakk>P\<rbrakk> \<or> x:\<lbrakk>Q\<rbrakk>) = x:\<lbrakk>P \<or> Q\<rbrakk>"
  by (rel_auto)

lemma frame_seq:
  "\<lbrakk> vwb_lens x; $x\<acute> \<sharp> P; $x \<sharp> Q \<rbrakk>  \<Longrightarrow> (x:\<lbrakk>P\<rbrakk> ;; x:\<lbrakk>Q\<rbrakk>) = x:\<lbrakk>P ;; Q\<rbrakk>"
  by (rel_simp, metis vwb_lens_def wb_lens_weak weak_lens.put_get)
    
lemma antiframe_to_frame:
  "\<lbrakk> x \<bowtie> y; x +\<^sub>L y = 1\<^sub>L \<rbrakk> \<Longrightarrow> x:[P] = y:\<lbrakk>P\<rbrakk>"
  by (rel_auto, metis lens_indep_def, metis lens_indep_def surj_pair)
    
lemma antiframe_skip [simp]:
  "vwb_lens x \<Longrightarrow> x:[II] = II"
  by (rel_auto)
    
lemma antiframe_assign_in:
  "\<lbrakk> vwb_lens a; x \<subseteq>\<^sub>L a \<rbrakk> \<Longrightarrow> a:[x := v] = x := v"
  by (rel_auto, simp_all add: lens_get_put_quasi_commute lens_put_of_quotient)

lemma antiframe_conj_true:
  "\<lbrakk> {$x,$x\<acute>} \<natural> P; vwb_lens x \<rbrakk> \<Longrightarrow> (P \<and> x:[true]) = x:[P]"
  by (rel_auto, metis vwb_lens_wb wb_lens.get_put)
    
lemma antiframe_assign:
  "vwb_lens x \<Longrightarrow> x:[$x\<acute> =\<^sub>u \<lceil>v\<rceil>\<^sub><] = x := v"
  by (rel_auto, metis mwb_lens_def vwb_lens_mwb weak_lens.put_get)
    
lemma nameset_skip: "vwb_lens x \<Longrightarrow> (ns x \<bullet> II) = II\<^bsub>x\<^esub>"
  by (rel_auto, meson vwb_lens_wb wb_lens.get_put)
    
lemma nameset_skip_ra: "vwb_lens x \<Longrightarrow> (ns x \<bullet> II\<^bsub>x\<^esub>) = II\<^bsub>x\<^esub>"
  by (rel_auto)

declare sublens_def [lens_defs]
    
subsection {* While Loop Laws *}

theorem while_unfold:
  "while b do P od = ((P ;; while b do P od) \<triangleleft> b \<triangleright>\<^sub>r II)"
proof -
  have m:"mono (\<lambda>X. (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (auto intro: monoI seqr_mono cond_mono)
  have "(while b do P od) = (\<nu> X \<bullet> (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (simp add: while_def)
  also have "... = ((P ;; (\<nu> X \<bullet> (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (subst lfp_unfold, simp_all add: m)
  also have "... = ((P ;; while b do P od) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (simp add: while_def)
  finally show ?thesis .
qed

theorem while_false: "while false do P od = II"
  by (subst while_unfold, simp add: aext_false)

theorem while_true: "while true do P od = false"
  apply (simp add: while_def alpha)
  apply (rule antisym)
  apply (simp_all)
  apply (rule lfp_lowerbound)
  apply (simp)
done

theorem while_bot_unfold:
  "while\<^sub>\<bottom> b do P od = ((P ;; while\<^sub>\<bottom> b do P od) \<triangleleft> b \<triangleright>\<^sub>r II)"
proof -
  have m:"mono (\<lambda>X. (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (auto intro: monoI seqr_mono cond_mono)
  have "(while\<^sub>\<bottom> b do P od) = (\<mu> X \<bullet> (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (simp add: while_bot_def)
  also have "... = ((P ;; (\<mu> X \<bullet> (P ;; X) \<triangleleft> b \<triangleright>\<^sub>r II)) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (subst gfp_unfold, simp_all add: m)
  also have "... = ((P ;; while\<^sub>\<bottom> b do P od) \<triangleleft> b \<triangleright>\<^sub>r II)"
    by (simp add: while_bot_def)
  finally show ?thesis .
qed

theorem while_bot_false: "while\<^sub>\<bottom> false do P od = II"
  by (simp add: while_bot_def mu_const alpha)

theorem while_bot_true: "while\<^sub>\<bottom> true do P od = (\<mu> X \<bullet> P ;; X)"
  by (simp add: while_bot_def alpha)

text {* An infinite loop with a feasible body corresponds to a program error (non-termination). *}

theorem while_infinite: "P ;; true\<^sub>h = true \<Longrightarrow> while\<^sub>\<bottom> true do P od = true"
  apply (simp add: while_bot_true)
  apply (rule antisym)
  apply (simp)
  apply (rule gfp_upperbound)
  apply (simp)
done

subsection {* Algebraic Properties *}

interpretation upred_semiring: semiring_1
  where times = seqr and one = skip_r and zero = false\<^sub>h and plus = Lattices.sup
  by (unfold_locales, (rel_auto)+)

text {* We introduce the power syntax derived from semirings *}

abbreviation upower :: "'\<alpha> hrel \<Rightarrow> nat \<Rightarrow> '\<alpha> hrel" (infixr "\<^bold>^" 80) where
"upower P n \<equiv> upred_semiring.power P n"

translations
  "P \<^bold>^ i" <= "CONST power.power II op ;; P i"
  "P \<^bold>^ i" <= "(CONST power.power II op ;; P) i"

text {* Set up transfer tactic for powers *}

lemma upower_rep_eq:
  "\<lbrakk>P \<^bold>^ i\<rbrakk>\<^sub>e = (\<lambda> b. b \<in> ({p. \<lbrakk>P\<rbrakk>\<^sub>e p} ^^ i))"
proof (induct i arbitrary: P)
  case 0
  then show ?case
    by (auto, rel_auto)
next
  case (Suc i)
  show ?case
    by (simp add: Suc seqr.rep_eq relpow_commute)
qed

lemma upower_rep_eq_alt:
  "\<lbrakk>power.power \<langle>id\<rangle>\<^sub>a op ;; P i\<rbrakk>\<^sub>e = (\<lambda>b. b \<in> ({p. \<lbrakk>P\<rbrakk>\<^sub>e p} ^^ i))"
  by (metis skip_r_def upower_rep_eq)

update_uexpr_rep_eq_thms
  
lemma Sup_power_expand:
  fixes P :: "nat \<Rightarrow> 'a::complete_lattice"
  shows "P(0) \<sqinter> (\<Sqinter>i. P(i+1)) = (\<Sqinter>i. P(i))"
proof -
  have "UNIV = insert (0::nat) {1..}"
    by auto
  moreover have "(\<Sqinter>i. P(i)) = \<Sqinter> (P ` UNIV)"
    by (blast)
  moreover have "\<Sqinter> (P ` insert 0 {1..}) = P(0) \<sqinter> SUPREMUM {1..} P"
    by (simp)
  moreover have "SUPREMUM {1..} P = (\<Sqinter>i. P(i+1))"
    by (simp add: atLeast_Suc_greaterThan)
  ultimately show ?thesis
    by (simp only:)
qed

lemma Sup_upto_Suc: "(\<Sqinter>i\<in>{0..Suc n}. P \<^bold>^ i) = (\<Sqinter>i\<in>{0..n}. P \<^bold>^ i) \<sqinter> P \<^bold>^ Suc n"
proof -
  have "(\<Sqinter>i\<in>{0..Suc n}. P \<^bold>^ i) = (\<Sqinter>i\<in>insert (Suc n) {0..n}. P \<^bold>^ i)"
    by (simp add: atLeast0_atMost_Suc)
  also have "... = P \<^bold>^ Suc n \<sqinter> (\<Sqinter>i\<in>{0..n}. P \<^bold>^ i)"
    by (simp)
  finally show ?thesis
    by (simp add: Lattices.sup_commute)
qed

text {* The following two proofs are adapted from the AFP entry 
  \href{https://www.isa-afp.org/entries/Kleene_Algebra.shtml}{Kleene Algebra}. 
  See also~\cite{Armstrong2012,Armstrong2015}. *}

lemma upower_inductl: "Q \<sqsubseteq> (P ;; Q \<sqinter> R) \<Longrightarrow> Q \<sqsubseteq> P \<^bold>^ n ;; R"
proof (induct n)
  case 0
  then show ?case by (auto)
next
  case (Suc n)
  then show ?case
    by (auto, metis (no_types, hide_lams) dual_order.trans order_refl seqr_assoc seqr_mono)
qed

lemma upower_inductr:
  assumes "Q \<sqsubseteq> (R \<sqinter> Q ;; P)"
  shows "Q \<sqsubseteq> R ;; (P \<^bold>^ n)"
using assms proof (induct n)
  case 0
  then show ?case by auto
next
  case (Suc n)
  have "R ;; P \<^bold>^ Suc n = (R ;; P \<^bold>^ n) ;; P"
    by (metis seqr_assoc upred_semiring.power_Suc2)
  also have "Q ;; P \<sqsubseteq> ..."
    by (meson Suc.hyps assms eq_iff seqr_mono)
  also have "Q \<sqsubseteq> ..."
    using assms by auto
  finally show ?case .
qed

lemma SUP_atLeastAtMost_first:
  fixes P :: "nat \<Rightarrow> 'a::complete_lattice"
  assumes "m \<le> n"
  shows "(\<Sqinter>i\<in>{m..n}. P(i)) = P(m) \<sqinter> (\<Sqinter>i\<in>{Suc m..n}. P(i))"
  by (metis SUP_insert assms atLeastAtMost_insertL)
    
lemma upower_seqr_iter: "P \<^bold>^ n = (;; Q : replicate n P \<bullet> Q)"
  by (induct n, simp_all)
    
subsubsection {* Kleene Star *}

definition ustar :: "'\<alpha> hrel \<Rightarrow> '\<alpha> hrel" ("_\<^sup>\<star>" [999] 999) where
"P\<^sup>\<star> = (\<Sqinter>i\<in>{0..} \<bullet> P\<^bold>^i)"

lemma ustar_rep_eq:
  "\<lbrakk>P\<^sup>\<star>\<rbrakk>\<^sub>e = (\<lambda>b. b \<in> ({p. \<lbrakk>P\<rbrakk>\<^sub>e p}\<^sup>*))"
  by (simp add: ustar_def, rel_auto, simp_all add: relpow_imp_rtrancl rtrancl_imp_relpow)

update_uexpr_rep_eq_thms
  
subsubsection {* Omega *}

definition uomega :: "'\<alpha> hrel \<Rightarrow> '\<alpha> hrel" ("_\<^sup>\<omega>" [999] 999) where
"P\<^sup>\<omega> = (\<mu> X \<bullet> P ;; X)"

subsection {* Relation Algebra Laws *}

theorem RA1: "(P ;; (Q ;; R)) = ((P ;; Q) ;; R)"
  by (simp add: seqr_assoc)

theorem RA2: "(P ;; II) = P" "(II ;; P) = P"
  by simp_all

theorem RA3: "P\<^sup>-\<^sup>- = P"
  by simp

theorem RA4: "(P ;; Q)\<^sup>- = (Q\<^sup>- ;; P\<^sup>-)"
  by simp

theorem RA5: "(P \<or> Q)\<^sup>- = (P\<^sup>- \<or> Q\<^sup>-)"
  by (rel_auto)

theorem RA6: "((P \<or> Q) ;; R) = (P;;R \<or> Q;;R)"
  using seqr_or_distl by blast

theorem RA7: "((P\<^sup>- ;; (\<not>(P ;; Q))) \<or> (\<not>Q)) = (\<not>Q)"
  by (rel_auto)

subsection {* Kleene Algebra Laws *}

theorem ustar_unfoldl: "P\<^sup>\<star> \<sqsubseteq> II \<sqinter> P;;P\<^sup>\<star>"
  by (rel_simp, simp add: rtrancl_into_trancl2 trancl_into_rtrancl)

theorem ustar_inductl:
  assumes "Q \<sqsubseteq> R" "Q \<sqsubseteq> P ;; Q"
  shows "Q \<sqsubseteq> P\<^sup>\<star> ;; R"
proof -
  have "P\<^sup>\<star> ;; R = (\<Sqinter> i. P \<^bold>^ i ;; R)"
    by (simp add: ustar_def UINF_as_Sup_collect' seq_SUP_distr)
  also have "Q \<sqsubseteq> ..."
    by (simp add: SUP_least assms upower_inductl)
  finally show ?thesis .
qed

theorem ustar_inductr:
  assumes "Q \<sqsubseteq> R" "Q \<sqsubseteq> Q ;; P"
  shows "Q \<sqsubseteq> R ;; P\<^sup>\<star>"
proof -
  have "R ;; P\<^sup>\<star> = (\<Sqinter> i. R ;; P \<^bold>^ i)"
    by (simp add: ustar_def UINF_as_Sup_collect' seq_SUP_distl)
  also have "Q \<sqsubseteq> ..."
    by (simp add: SUP_least assms upower_inductr)
  finally show ?thesis .
qed

lemma ustar_refines_nu: "(\<nu> X \<bullet> P ;; X \<sqinter> II) \<sqsubseteq> P\<^sup>\<star>"
  by (metis (no_types, lifting) lfp_greatest semilattice_sup_class.le_sup_iff 
      semilattice_sup_class.sup_idem upred_semiring.mult_2_right 
      upred_semiring.one_add_one ustar_inductl)

lemma ustar_as_nu: "P\<^sup>\<star> = (\<nu> X \<bullet> P ;; X \<sqinter> II)"
proof (rule antisym)
  show "(\<nu> X \<bullet> P ;; X \<sqinter> II) \<sqsubseteq> P\<^sup>\<star>"
    by (simp add: ustar_refines_nu)
  show "P\<^sup>\<star> \<sqsubseteq> (\<nu> X \<bullet> P ;; X \<sqinter> II)"
    by (metis lfp_lowerbound upred_semiring.add_commute ustar_unfoldl)
qed
  
subsection {* Omega Algebra Laws *}

lemma uomega_induct:
  "P ;; P\<^sup>\<omega> \<sqsubseteq> P\<^sup>\<omega>"
  by (simp add: uomega_def, metis eq_refl gfp_unfold monoI seqr_mono)

subsection {* Refinement Laws *}

lemma conj_refine_left:
  "(Q \<Rightarrow> P) \<sqsubseteq> R \<Longrightarrow> P \<sqsubseteq> (Q \<and> R)"
  by (rel_auto)
  
lemma pre_weak_rel:
  assumes "`Pre \<Rightarrow> I`"
  and     "(I \<Rightarrow> Post) \<sqsubseteq> P"
  shows "(Pre \<Rightarrow> Post) \<sqsubseteq> P"
  using assms by(rel_auto)
    
lemma cond_refine_rel: 
  assumes "S \<sqsubseteq> (\<lceil>b\<rceil>\<^sub>< \<and> P)" "S \<sqsubseteq> (\<lceil>\<not>b\<rceil>\<^sub>< \<and> Q)"
  shows "S \<sqsubseteq> P \<triangleleft> b \<triangleright>\<^sub>r Q"
  by (metis aext_not assms cond_def utp_pred_laws.le_sup_iff)

lemma seq_refine_pred:
  assumes "(\<lceil>b\<rceil>\<^sub>< \<Rightarrow> \<lceil>s\<rceil>\<^sub>>) \<sqsubseteq> P" and "(\<lceil>s\<rceil>\<^sub>< \<Rightarrow> \<lceil>c\<rceil>\<^sub>>) \<sqsubseteq> Q"
  shows "(\<lceil>b\<rceil>\<^sub>< \<Rightarrow> \<lceil>c\<rceil>\<^sub>>) \<sqsubseteq> (P ;; Q)"
  using assms by rel_auto
    
lemma seq_refine_unrest:
  assumes "out\<alpha> \<sharp> b" "in\<alpha> \<sharp> c"
  assumes "(b \<Rightarrow> \<lceil>s\<rceil>\<^sub>>) \<sqsubseteq> P" and "(\<lceil>s\<rceil>\<^sub>< \<Rightarrow> c) \<sqsubseteq> Q"
  shows "(b \<Rightarrow> c) \<sqsubseteq> (P ;; Q)"
  using assms by rel_blast 
    
    
    
end