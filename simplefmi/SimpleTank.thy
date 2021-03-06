theory SimpleTank
  imports 
    VDMRT
    SimpleFMI
    "../hybrid/utp_hybrid"
    "../theories/utp_reactive_hoare"
begin recall_syntax
  
alphabet tank_st =
  valve   :: bool
  level   :: real
  
setup_lifting type_definition_tank_st_ext
  
text {* Proof that the state-space is a T2 topological space. *}
  
instantiation tank_st_ext :: (t2_space) t2_space
begin
  lift_definition open_tank_st_ext :: "'a tank_st_scheme set \<Rightarrow> bool" is "open" .
  instance by (intro_classes, (transfer, auto simp add: separation_t2)+)
end

lemma continuous_Rep_tank_st_ext [continuous_intros]:
  "continuous_on UNIV Rep_tank_st_ext"
  by (metis continuous_on_open_vimage image_vimage_eq open_Int open_UNIV open_tank_st_ext.rep_eq)
  
alphabet ctr_st = vrt_st +
  valveOn     :: bool
  levelSensor :: real
  
alphabet wt_st =
  tank  :: tank_st
  ctr   :: "ctr_st vrt_st_scheme"
    
definition
  "Init = [ tank:valve      \<mapsto>\<^sub>s true
          , tank:level      \<mapsto>\<^sub>s 0
          , ctr:valveOn     \<mapsto>\<^sub>s false
          , ctr:levelSensor \<mapsto>\<^sub>s 0 ]"
  
definition 
  "Wiring = [ tank:valve      \<mapsto>\<^sub>s &ctr:valveOn
            , ctr:levelSensor \<mapsto>\<^sub>s &tank:level ]"

abbreviation (input) tank_ode_1 :: "real \<Rightarrow> real \<Rightarrow> real" where
"tank_ode_1 \<equiv> (\<lambda> t l. 1)"

abbreviation (input) tank_ode_2 :: "real \<Rightarrow> real \<Rightarrow> real" where
"tank_ode_2 \<equiv> (\<lambda> t l. -1)"

abbreviation (input) tank_sol_1 :: "real \<Rightarrow> real \<Rightarrow> real" where
"tank_sol_1 \<equiv> (\<lambda> l\<^sub>0 t. l\<^sub>0 + t)"

abbreviation (input) tank_sol_2 :: "real \<Rightarrow> real \<Rightarrow> real" where
"tank_sol_2 \<equiv> (\<lambda> l\<^sub>0 t. l\<^sub>0 - t)"
  
lemma tank_ode_usol_1:
  "l > 0 \<Longrightarrow> (tank_sol_1 l\<^sub>0 usolves_ode tank_ode_1 from 0) {0..l} UNIV"
  by (linear_ode)

lemma tank_ode_usol_2:
  "l > 0 \<Longrightarrow> (tank_sol_2 l\<^sub>0 usolves_ode tank_ode_2 from 0) {0..l} UNIV"
  by (linear_ode)
    
definition Tank  :: "real \<Rightarrow> tank_st trel" where 
  "Tank area = H2T((\<langle>{&level} : tank_ode_1(ti)\<rangle>\<^sub>h \<and> level \<leftarrow>\<^sub>h $level) 
                     \<triangleleft> &valve \<triangleright>\<^sub>h 
                   (\<langle>{&level} : tank_ode_2(ti)\<rangle>\<^sub>h \<and> level \<leftarrow>\<^sub>h $level))"

definition Ctr :: "real \<Rightarrow> real \<Rightarrow> ctr_st vrel" where
"Ctr minLevel maxLevel = 
  Periodic 0.001 (valveOn := true \<triangleleft> &levelSensor \<le>\<^sub>u \<guillemotleft>minLevel\<guillemotright> \<triangleright>\<^sub>r 
                  valveOn := false \<triangleleft> &levelSensor \<ge>\<^sub>u \<guillemotleft>maxLevel\<guillemotright> \<triangleright>\<^sub>r II)"
  
definition
  "WaterTank minLevel maxLevel area = 
     FMI Init [FMU[ctr, Ctr minLevel maxLevel], FMU[tank, Tank area]] ArbStep Wiring"

        
lemma fmu_hoare_rp [hoare_safe]:
  "\<lbrakk> x \<natural> p; \<lbrace>p\<restriction>\<^sub>px\<rbrace>Q\<lbrace>p\<restriction>\<^sub>px\<rbrace>\<^sub>r \<rbrakk> \<Longrightarrow> \<lbrace>p\<rbrace>FMU[x, Q]\<lbrace>p\<rbrace>\<^sub>r"
  apply (rel_simp, auto simp add: des_vars.defs rp_vars.defs)
  apply (rename_tac ok wait tr st ok' wait' tr' st')
  apply (drule_tac x="ok" in spec)
  apply (drule_tac x="wait" in spec)
  apply (drule_tac x="tr" in spec)
  apply (drule_tac x="get\<^bsub>x\<^esub> st" in spec)
  apply (drule_tac x="ok'" in spec)
  apply (drule_tac x="wait'" in spec)
  apply (drule_tac x="tr'" in spec)
  apply (drule_tac x="get\<^bsub>x\<^esub> st'" in spec)
  apply (auto)
done
  
lemma tank_ode_1_evolve:
  "\<langle>{&level} : tank_ode_1(ti)\<rangle>\<^sub>h = {[&level \<mapsto>\<^sub>s \<guillemotleft>op +\<guillemotright>(&level)\<^sub>a(\<guillemotleft>ti\<guillemotright>)\<^sub>a]}\<^sub>h"
  by (ode_fsolve tank_sol_1)

lemma tank_ode_2_evolve:
  "\<langle>{&level} : tank_ode_2(ti)\<rangle>\<^sub>h = {[&level \<mapsto>\<^sub>s \<guillemotleft>op -\<guillemotright>(&level)\<^sub>a(\<guillemotleft>ti\<guillemotright>)\<^sub>a]}\<^sub>h"
  by (ode_fsolve tank_sol_2) 
    
lemma continuous_lens_level [closure]: "continuous_lens level"
  apply (unfold_locales, simp_all add: lens_defs prod.case_eq_if)
  apply (simp add: tank_st.select_defs iso_tuple_fst_def tuple_iso_tuple_def 
      tank_st_ext_Tuple_Iso_def Topological_Spaces.continuous_on_fst continuous_Rep_tank_st_ext)
  sorry
    
    
lemma "H2T(\<langle>&level : \<lambda>lev. 1\<rangle>\<^sub>h \<triangleleft> &valve \<triangleright>\<^sub>h \<langle>&level : \<lambda>lev. - 1\<rangle>\<^sub>h) = undefined"
  apply (simp add: hyrel2trl_cond hyrel2trel_hEvolves tank_ode_1_evolve tank_ode_2_evolve closure)
  thm hyrel2trel_hEvolves
    thm hyrel2trel_hEvolves
  apply (subst hyrel2trel_hEvolves)
    
lemma "\<lbrace>true\<rbrace>WaterTank 0 10 10\<lbrace>&tank:level <\<^sub>u 10 \<and> &ctr:levelSensor <\<^sub>u 10\<rbrace>\<^sub>r"
  apply (simp add: conj_comm conj_assoc)
  apply (simp add: WaterTank_def Ctr_def Tank_def FMI_def)
  apply (rule hoare_safe)
   apply (rule hoare_safe)
   apply (simp add: Init_def)
   apply (rel_auto)
  apply (rule hoare_safe)
  apply (rule hoare_safe)
  apply (rule hoare_safe)
    apply (rule hoare_safe)
     apply (simp add: unrest)
    apply (simp add: Periodic_def PeriodicBody_def)
    apply (rule hoare_safe)
     apply (rule hoare_safe)
     apply (rel_auto)
        apply (rel_auto)
    apply (
     apply (rule unrest)
  apply (simp add: unrest)
(*
  apply (rule hoare)
   apply (rule hoare_safe)
   apply (simp add: Init_def)
   apply (rel_auto)
oops
*)

end