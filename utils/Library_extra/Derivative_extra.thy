section {* Derivatives: extra laws and tactics *}

theory Derivative_extra
imports 
  "~~/src/HOL/Eisbach/Eisbach"
  "~~/src/HOL/Library/Product_Vector"
  "~~/src/HOL/Multivariate_Analysis/Derivative"
begin

subsection {* Properties of filters *}

lemma filtermap_within_range_minus: "filtermap (\<lambda> x. x - n::real) (at y within {x..<y}) = (at (y - n) within ({x-n..<y-n}))"
  by (simp add: filter_eq_iff eventually_filtermap eventually_at_filter filtermap_nhds_shift[symmetric])

lemma filtermap_within_range_plus: "filtermap (\<lambda> x. x + n::real) (at y within {x..<y}) = (at (y + n) within ({x+n..<y+n}))"
  using filtermap_within_range_minus[of "-n"] by simp

lemma filter_upto_contract:
  "\<lbrakk> (x::real) \<le> y; y < z \<rbrakk> \<Longrightarrow> (at z within {x..<z}) = (at z within {y..<z})"
  by (rule at_within_nhd[of _ "{y<..<z+1}"], auto)

subsection {* Extra derivative rules *}

lemma has_vector_derivative_Pair [derivative_intros]:
  "\<lbrakk> (f has_vector_derivative f') (at x within s); (g has_vector_derivative g') (at x within s) \<rbrakk> \<Longrightarrow>
      ((\<lambda> x. (f x, g x)) has_vector_derivative (f', g')) (at x within s)"
  by (auto intro: has_derivative_Pair simp add: has_vector_derivative_def)

lemma has_vector_derivative_power[simp, derivative_intros]:
  fixes f :: "real \<Rightarrow> 'a :: real_normed_field"
  assumes f: "(f has_vector_derivative f') (at x within s)"
  shows "((\<lambda>x. f x^n) has_vector_derivative (of_nat n * f' * f x^(n - 1))) (at x within s)"
  using assms
  apply (simp add: has_vector_derivative_def)
  apply (subst has_derivative_eq_rhs)
  apply (rule has_derivative_power)
  apply (auto)
done

lemma has_vector_derivative_divide[simp, derivative_intros]:
  fixes f :: "real \<Rightarrow> 'a :: real_normed_div_algebra"
  assumes f: "(f has_vector_derivative f') (at x within s)" 
      and g: "(g has_vector_derivative g') (at x within s)" 
  assumes x: "g x \<noteq> 0"
  shows "((\<lambda>x. f x / g x) has_vector_derivative
                (- f x * (inverse (g x) * g' * inverse (g x)) + f' / g x)) (at x within s)"
  using assms
  apply (simp add: has_vector_derivative_def)
  apply (subst has_derivative_eq_rhs)
  apply (rule has_derivative_divide)
  apply (auto simp add: divide_inverse real_vector.scale_right_diff_distrib)
done

text {* vderiv\_tac is a simple tactic for certifying solutions to systems of differential equations *}

method vderiv_tac = (safe intro!: has_vector_derivative_Pair, (rule has_vector_derivative_eq_rhs, (rule derivative_intros; (simp)?)+, simp)+)

end