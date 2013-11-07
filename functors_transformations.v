(** **********************************************************

Benedikt Ahrens, Chris Kapulkin, Mike Shulman
january 2013


************************************************************)


(** **********************************************************

Contents :  

		- Functors
                  - preserve isos, inverses
                                    
                  - fully faithful functors
                    - preserve isos, inverses, composition 
                            backwards
                    
                  - essentially surjective
                  - faithful
                  - full
                  - fully faithful is the same as full and faithful
                  
                  - Image of a functor, full subcat specified
                                       by a functor
                 
                      
                      
		- Natural transformations
                  - Equality is pointwise equality.
                  
                  
		- Functor (pre)category			
                  - Isomorphisms in functor category are pointwise
                         isomorphisms
                         
                - Isomorphic Functors are equal
                   if target precategory is category
                   [functor_eq_from_functor_iso]
                  
                - Functor precategory is category if
                   target precategory is
                   [is_category_functor_category]
		
		           
************************************************************)


Require Import Foundations.Generalities.uu0.
Require Import Foundations.hlevel1.hProp.
Require Import Foundations.hlevel2.hSet.

Require Import RezkCompletion.pathnotations.
Import RezkCompletion.pathnotations.PathNotations.

Require Import RezkCompletion.auxiliary_lemmas_HoTT.

Require Import RezkCompletion.precategories.

Local Notation "a --> b" := (precategory_morphisms a b)(at level 50).
Local Notation "f ;; g" := (compose f g)(at level 50).

Ltac pathvia b := (apply (@pathscomp0 _ _ b _ )).




(** * Functors : Morphisms of precategories *)


Definition functor_data (C C' : precategory_ob_mor) := total2 (
    fun F : ob C -> ob C' => 
             forall a b : ob C, a --> b -> F a --> F b).

Definition functor_on_objects {C C' : precategory_ob_mor}
     (F : functor_data C C') :  ob C -> ob C' := pr1 F.
Coercion functor_on_objects : functor_data >-> Funclass.


Definition functor_on_morphisms {C C' : precategory_ob_mor} (F : functor_data C C') 
  { a b : ob C} :  a --> b -> F a --> F b := pr2 F a b.

Local Notation "# F" := (functor_on_morphisms F)(at level 3).


Definition is_functor {C C' : precategory_data} (F : functor_data C C') :=
     dirprod (forall a : ob C, #F (identity a) == identity (F a))
             (forall a b c : ob C, forall f : a --> b, forall g : b --> c, 
                #F (f ;; g) == #F f ;; #F g).

Lemma isaprop_is_functor (C C' : precategory_data) 
       (F : functor_data C C'): isaprop (is_functor F).
Proof.
  apply isofhleveldirprod.
  apply impred; intro a.
  apply (pr2 (_ --> _)).
  apply impred; intro a.
  apply impred; intro b.
  apply impred; intro c.
  apply impred; intro f.
  apply impred; intro g.
  apply (pr2 (_ --> _)).
Qed.

Definition functor (C C' : precategory_data) := total2 (
   fun F : functor_data C C' => is_functor F).

Lemma functor_eq (C C' : precategory_data) (F F': functor C C'):
    pr1 F == pr1 F' -> F == F'.
Proof.
  intro H.
  apply (total2_paths H).
  apply proofirrelevance.
  apply isaprop_is_functor.
Defined.

Definition functor_data_from_functor (C C': precategory_data)
     (F : functor C C') : functor_data C C' := pr1 F.
Coercion functor_data_from_functor : functor >-> functor_data.


Definition functor_eq_eq_from_functor_ob_eq (C C' : precategory_data)
   (F G : functor C C') (p q : F == G) 
   (H : base_paths _ _ (base_paths _ _  p) == 
         base_paths _ _ (base_paths _ _ q)) :
    p == q.
Proof.
  apply equal_equalities_between_pairs.
  simpl.
  assert (H' : base_paths _ _ p == base_paths _ _ q).
  apply equal_equalities_between_pairs.
  simpl. 
  apply (@total2_paths2 _ (fun p : pr1 (pr1 F) == pr1 (pr1 G) =>
          transportf
            (fun x : ob C -> ob C' =>
            (fun x0 : ob C -> ob C' => 
            forall a b : ob C, a --> b -> x0 a --> x0 b) x)
            p (pr2 (pr1 F)) == pr2 (pr1 G)) _ 
   (fiber_path_fibr (base_paths F G p)) _ (fiber_path_fibr (base_paths F G q))  H).
   apply uip.
   change (isaset) with (isofhlevel 2).
   apply impred.
   intro a.
   apply impred.
   intro b.
   apply impred.
   intro f.
   apply (pr2 (_ --> _)).
   apply (@total2_paths2 (pr1 F == pr1 G)  
    (fun x : pr1 F == pr1 G => transportf _ x (pr2 F) == pr2 G)
          (base_paths F G p) (fiber_path_fibr p) (base_paths F G q) (fiber_path_fibr q) H').
   apply uip.
   apply isasetaprop.
   apply isaprop_is_functor.
Defined.


(*
Definition functor_eq_eq_from_functor_ob_eq (C C' : precategory_data)
   (F G : functor C C') (p q : F == G) 
   (H : functor_ob_eq_from_functor_eq _ _ _ _ p == 
         functor_ob_eq_from_functor_eq _ _ _ _ q) :
    p == q.
Proof.
  assert (H' : base_paths _ _ p == base_paths _ _ q).
  unfold base_paths.
  unfold functor_ob_eq_from_functor_eq in H.
  unfold base_paths in H.
  simpl in *.
  apply (total2_paths H).
  simpl.
*)
  

Definition functor_id (C C' : precategory_data)(F : functor C C'):
       forall a : ob C, #F (identity a) == identity (F a) := pr1 (pr2 F).

Definition functor_comp (C C' : precategory_data)
      (F : functor C C'):
       forall a b c : ob C, forall f : a --> b,
                 forall g : b --> c, 
                #F (f ;; g) == #F f ;; #F g := pr2 (pr2 F).

(** ** Functors preserve isomorphisms *)

Lemma functor_on_iso_is_iso (C C' : precategory) (F : functor C C')
    (a b : ob C)(f : iso a b) : is_isomorphism (#F f).
Proof.
  exists (#F (inv_from_iso f)).
  simpl; split; simpl.
  rewrite <- functor_comp.
  rewrite iso_inv_after_iso.
  apply functor_id.
  
  rewrite <- functor_comp.
  rewrite (iso_after_iso_inv _ _ _ f).
  apply functor_id.
Qed.


Definition functor_on_iso (C C' : precategory) (F : functor C C')
    (a b : ob C)(f : iso a b) : iso (F a) (F b).
Proof.
  exists (#F f).
  apply functor_on_iso_is_iso.
Defined.
 
Lemma functor_on_iso_inv (C C' : precategory) (F : functor C C')
    (a b : ob C) (f : iso a b) : 
   functor_on_iso _ _ F _ _ (iso_inv_from_iso f) == 
       iso_inv_from_iso (functor_on_iso _ _ F _ _ f).
Proof.
  apply inv_iso_unique.
  simpl.
  split; simpl.
  rewrite <- functor_comp.
  rewrite iso_inv_after_iso.
  apply functor_id.
  rewrite <- functor_comp.
  rewrite iso_after_iso_inv.
  apply functor_id.
Qed.
  
(** ** Functors preserve inverses *)

Lemma functor_on_inv_from_iso (C C' : precategory) (F : functor C C')
    (a b : ob C)(f : iso a b) :
      #F (inv_from_iso f) == inv_from_iso (functor_on_iso _ _ F _ _ f) .
Proof.
  set (H := functor_on_iso_inv _ _ F _ _ f).
  set (H' := base_paths _ _ H). simpl in *.
  apply H'.
Qed. 


(** ** Fully faithful functors *)

Definition fully_faithful {C D : precategory} (F : functor C D) := 
  forall a b : ob C, 
    isweq (functor_on_morphisms F (a:=a) (b:=b)).

Lemma isaprop_fully_faithful (C D : precategory) (F : functor C D) :
   isaprop (fully_faithful F).
Proof.
  apply impred; intro a.
  apply impred; intro b.
  apply isapropisweq.
Qed.

Definition weq_from_fully_faithful (C D : precategory) (F : functor C D) 
      (HF : fully_faithful F) (a b : ob C) : 
   weq (a --> b) (F a --> F b).
Proof.
  exists (functor_on_morphisms F (a:=a) (b:=b)).
  exact (HF a b).
Defined.


Definition fully_faithful_inv_hom (C D : precategory) (F : functor C D) 
      (HF : fully_faithful F) (a b : ob C) :
      F a --> F b -> a --> b :=
 invweq (weq_from_fully_faithful C D F HF a b).

Lemma fully_faithful_inv_identity (C D : precategory) (F : functor C D)
      (HF : fully_faithful F) (a : ob C) : 
    fully_faithful_inv_hom _ _ _ HF _ _ (identity (F a)) == identity _ .
Proof.
  set (h' := equal_transport_along_weq _ _ (weq_from_fully_faithful _ _ _ HF a a)).
  apply h'.
  set (HFFaa := homotweqinvweq (weq_from_fully_faithful _ _ _ HF a a)
                 (identity _ )).
  unfold fully_faithful_inv_hom.
  simpl in *.
  rewrite HFFaa.
  rewrite functor_id; apply idpath.
Qed.


Lemma fully_faithful_inv_comp (C D : precategory) (F : functor C D)
      (HF : fully_faithful F) (a b c : ob C) 
      (f : F a --> F b) (g : F b --> F c) : 
    fully_faithful_inv_hom _ _ _ HF _ _ (f ;; g) ==
       fully_faithful_inv_hom _ _ _ HF _ _ f ;; 
           fully_faithful_inv_hom _ _ _ HF _ _ g.
Proof.
  set (h' := equal_transport_along_weq _ _ (weq_from_fully_faithful _ _ _ HF a c)).
  apply h'.
  set (HFFac := homotweqinvweq (weq_from_fully_faithful _ _ _ HF a c)
                 (f ;; g)).
  unfold fully_faithful_inv_hom.
  simpl in *.
  rewrite HFFac.
  rewrite functor_comp.
  set (HFFab := homotweqinvweq (weq_from_fully_faithful _ _ _ HF a b) f).
  set (HFFbc := homotweqinvweq (weq_from_fully_faithful _ _ _ HF b c) g).
  simpl in *.
  rewrite HFFab.
  rewrite HFFbc.
  apply idpath.
Qed.



(** *** Fully faithful functors reflect isos *)

Lemma fully_faithful_reflects_iso_proof (C D : precategory)(F : functor C D) 
        (HF : fully_faithful F)
    (a b : ob C) (f : iso (F a) (F b)) : 
     is_isomorphism (fully_faithful_inv_hom C D F HF a b f).
Proof.
  exists (fully_faithful_inv_hom C D F HF b a (inv_from_iso f)).
  simpl.
  unfold fully_faithful_inv_hom.
  split.
(*  unfold weq_from_fully_faithful.*)
  set (hhh := equal_transport_along_weq _ _ (weq_from_fully_faithful C D F HF a a)).
  apply hhh.
  set (HFFab := homotweqinvweq (weq_from_fully_faithful C D F HF a b)).
  set (HFFba := homotweqinvweq (weq_from_fully_faithful C D F HF b a)).
  simpl in *.
  rewrite functor_comp.
  rewrite HFFab.
  rewrite HFFba.
  rewrite functor_id.
  apply iso_inv_after_iso.
  
  set (hhh := equal_transport_along_weq _ _ (weq_from_fully_faithful C D F HF b b)).
  apply hhh.
  set (HFFab := homotweqinvweq (weq_from_fully_faithful C D F HF a b)).
  set (HFFba := homotweqinvweq (weq_from_fully_faithful C D F HF b a)).
  simpl in *.
  rewrite functor_comp.
  rewrite HFFab.
  rewrite HFFba.
  rewrite functor_id.
  set (Hff := pr2 (pr2 (pr2 f))).
  simpl in *.
  unfold inv_from_iso.
  destruct f.
  simpl. assumption.
Qed.

Definition  iso_from_fully_faithful_reflection (C D : precategory)(F : functor C D) 
        (HF : fully_faithful F)
    (a b : ob C) (f : iso (F a) (F b)) : 
      iso a b.
Proof.
  exists (fully_faithful_inv_hom C D F HF a b f).
  apply fully_faithful_reflects_iso_proof.
Defined.

Lemma functor_on_iso_iso_from_fully_faithful_reflection (C D : precategory)
      (F : functor C D) (HF : fully_faithful F) (a b : ob C)
   (f : iso (F a) (F b)) :
      functor_on_iso _ _  F a b
        (iso_from_fully_faithful_reflection _ _  F HF a b f) == f.
Proof.
  apply eq_iso.
  simpl.
  set (H3 := homotweqinvweq (weq_from_fully_faithful _ _ _ HF a b)).
  simpl in H3.
  unfold fully_faithful_inv_hom. simpl.
  rewrite H3.
  apply idpath.
Qed.



(** ** Essentially surjective functors *)

Definition essentially_surjective {C D : precategory} (F : functor C D) :=
  forall b, ishinh (total2 (fun a => iso (F a) b)).
   
(** ** Faithful functors *)

Definition faithful {C D : precategory} (F : functor C D) := 
  forall a b : ob C, forall f g : a --> b,
       #F f == #F g -> f == g.

Lemma isaprop_faithful (C D : precategory) (F : functor C D) : 
   isaprop (faithful F).
Proof.
  apply impred; intro c.
  apply impred; intro b.
  apply impred; intro f.
  apply impred; intro g.
  apply impred; intro H.
  apply (pr2 (c --> b)).
Qed.

(** ** Full functors *)

Definition full {C D : precategory} (F : functor C D) :=
   forall a b (g : F a --> F b), total2 (fun f : a --> b => #F f == g).





(** ** Fully faithful is the same as full and faithful *)

Definition full_and_faithful {C D : precategory} (F : functor C D) :=
   dirprod (full F) (faithful F).



Lemma fully_faithful_implies_full_and_faithful (C D : precategory) (F : functor C D) :
   fully_faithful F -> full_and_faithful F.
Proof.
  intro H.
  split; simpl.
  unfold full. 
  intros a b f.
  exists (fully_faithful_inv_hom _ _ _ H _ _ f).
  set (HFFaa := homotweqinvweq (weq_from_fully_faithful _ _ _ H a b)).
  simpl in HFFaa.
  apply HFFaa.
  
  unfold faithful.
  intros a b f g Heq.
  apply (equal_transport_along_weq _ _ (weq_from_fully_faithful C D F H a b)).
  simpl. assumption.
Qed.

Lemma full_and_faithful_implies_fully_faithful (C D : precategory) (F : functor C D) :
   full_and_faithful F -> fully_faithful F.
Proof. 
  intros [Hfull Hfaith].
  intros a b g.
  unfold full in Hfull.
  exists (Hfull a b g).
  unfold hfiber.
  intro t.
  unfold faithful in Hfaith.
  assert (X : pr1 t == pr1 (Hfull a b g)).
  apply Hfaith.
  rewrite (pr2 t). 
  set (H':= pr2 (Hfull a b g)).
  simpl in H'.
  rewrite H'. apply idpath.
  simpl in *.
  apply (total2_paths  X).
  apply proofirrelevance.
  apply (pr2 (F a --> F b)).
Qed.
 
Lemma isaprop_full_and_faithful (C D : precategory) (F : functor C D) :
   isaprop (full_and_faithful F).
Proof.
  apply isofhlevelsn.
  intro H.
  apply isofhleveldirprod.
  apply impred; intro b.
  apply impred; intro c.
  apply impred; intro g.
  apply invproofirrelevance.
  intros f f'.
  assert (HH : pr1 f == pr1 f').
  
  set (HF := full_and_faithful_implies_fully_faithful _ _ _ H).
  set (h' := equal_transport_along_weq _ _
          (weq_from_fully_faithful _ _ _ HF b c)).
       apply h'.
       simpl.
  rewrite (pr2 f).
  rewrite (pr2 f').
  apply idpath.
  
  apply (total2_paths HH).
  apply proofirrelevance.
  apply (pr2 (F b --> F c)).
  
  apply isaprop_faithful.
Qed.
  
  
Definition weq_fully_faithful_full_and_faithful (C D : precategory) (F : functor C D) :
   weq (fully_faithful F) (full_and_faithful F) :=
  weqimplimpl (fully_faithful_implies_full_and_faithful _ _ F)
              (full_and_faithful_implies_fully_faithful _ _ F)
              (isaprop_fully_faithful _ _ F)
              (isaprop_full_and_faithful _ _ F).

(** ** Image on objects of a functor  *)
(** is used later to define the full image subcategory of a category [D] 
       defined by a functor [F : C -> D] *)

Definition is_in_img_functor {C D : precategory} (F : functor C D) 
      (d : ob D) :=
  ishinh (
  total2 (fun c : ob C => iso (F c) d)).

Definition sub_img_functor {C D : precategory}(F : functor C D) :
    hsubtypes (ob D) := 
       fun d : ob D => is_in_img_functor F d.



(** ** Composition of Functors, Identity Functors *)

(** *** Composition *)
Lemma functor_composite_ob_mor {C C' C'' : precategory}
       (F : functor C C') (F' : functor C' C'') :
 is_functor  
  (tpair (fun F : ob C -> ob C'' => 
             forall a b : ob C, a --> b -> F a --> F b) 
    (fun a => F' (F a))
               (fun (a b : ob C) f => #F' (#F f))).
Proof.
  split;
  simpl.
  intro a.
  rewrite functor_id.
  rewrite functor_id.
  apply (idpath _).
  
  intros a b c f g.
  rewrite functor_comp.
  rewrite functor_comp.
  apply idpath.
Qed.

Definition functor_composite (C C' C'' : precategory)
       (F : functor C C') (F' : functor C' C'') :
  functor C C'' := tpair _ _ (functor_composite_ob_mor F F').

(** *** Identity functor *)

Lemma functor_identity_ob_mor (C : precategory) :
 is_functor  
  (tpair (fun F : ob C -> ob C => 
             forall a b : ob C, a --> b -> F a --> F b) 
    (fun a => a)
               (fun (a b : ob C) f => f)).
Proof.
  split;
  simpl.
  intro a.
  apply (idpath _).
  
  intros a b c f g.
  apply idpath.
Qed.

Definition functor_identity (C : precategory) :
     functor C  C.
Proof.
  exists (tpair (fun F : ob C -> ob C => 
             forall a b : ob C, a --> b -> F a --> F b) 
    (fun a => a)
               (fun (a b : ob C) f => f)).
  apply  (functor_identity_ob_mor C).
Defined.


    


(** * Natural transformations *)

(*
Definition functor_fun_data {C C' : precategory_data}
  (F F' : precategory_ob_mor_fun C C') :=
     forall x : ob C, F x --> F' x.
*)

(** ** Definition of natural transformations *)

Definition is_nat_trans {C C' : precategory_data}
  (F F' : functor_data C C')
  (t : forall x : ob C, F x -->  F' x) := 
  forall (x x' : ob C)(f : x --> x'),
    #F f ;; t x' == t x ;; #F' f.


Lemma isaprop_is_nat_trans (C C' : precategory_data)
  (F F' : functor_data C C') (t : forall x : ob C, F x -->  F' x):
  isaprop (is_nat_trans F F' t).
Proof.
  apply impred; intro x.
  apply impred; intro x'.
  apply impred; intro f.
  apply (pr2 (_ --> _)).
Qed.


Definition nat_trans {C C' : precategory_data}
  (F F' : functor_data C C') := total2 (
   fun t : forall x : ob C, F x -->  F' x => is_nat_trans F F' t).

Lemma isaset_nat_trans {C C' : precategory_data}
  (F F' : functor_data C C') : isaset (nat_trans F F').
Proof.
  change isaset with (isofhlevel 2).
  apply isofhleveltotal2.
  apply impred.
  intro t. apply (pr2 (_ --> _)).
  intro x. 
  apply isasetaprop.
  apply isaprop_is_nat_trans.
Qed.

Definition nat_trans_data (C C' : precategory_data)
 (F F' : functor_data C C')(a : nat_trans F F') :
   forall x : ob C, F x --> F' x := pr1 a.
Coercion nat_trans_data : nat_trans >-> Funclass.

Definition nat_trans_ax {C C' : precategory_data}
  (F F' : functor_data C C') (a : nat_trans F F') :
  forall (x x' : ob C)(f : x --> x'),
    #F f ;; a x' == a x ;; #F' f := pr2 a.

(** Equality between two natural transformations *)

Lemma nat_trans_eq {C C' : precategory_data}
  (F F' : functor_data C C')(a a' : nat_trans F F'):
  (forall x, a x == a' x) -> a == a'.
Proof.
  intro H.
  assert (H' : pr1 a == pr1 a').
  apply funextsec.
  assumption.
  apply (total2_paths H').
  apply proofirrelevance.
  apply isaprop_is_nat_trans.
Qed.

Definition nat_trans_eq_pointwise (C C' : precategory_data)
   (F F' : functor_data C C') (a a' : nat_trans F F'):
      a == a' -> forall x, a x == a' x.
Proof.
  intro h.
  apply toforallpaths.
  apply maponpaths.
  assumption.
Qed.


(** ** Functor category [[C, D]] *)

Definition functor_precategory_ob_mor (C C' : precategory_data): 
  precategory_ob_mor := precategory_ob_mor_pair 
   (functor C C') (fun F F' : functor C C' =>
                              hSetpair (nat_trans F F') 
                                       (isaset_nat_trans F F')).

(** *** Identity natural transformation *)

Lemma is_nat_trans_id {C C' : precategory}
  (F : functor_data C C') : is_nat_trans F F
     (fun c : ob C => identity (F c)).
Proof.
  intros c c' f.
  rewrite id_left.
  rewrite id_right.
  apply idpath.
Qed.

Definition nat_trans_id {C C' : precategory}
  (F : functor_data C C') : nat_trans F F :=
    tpair _ _ (is_nat_trans_id F).

(** *** Composition of natural transformations *)

Lemma is_nat_trans_comp {C C' : precategory}
  {F G H : functor_data C C'}
  (a : nat_trans F G)
  (b : nat_trans G H): is_nat_trans F H
     (fun x : ob C => a x ;; b x).
Proof.
  intros c c' f.
  rewrite assoc.
  rewrite nat_trans_ax.
  rewrite <- assoc.
  rewrite nat_trans_ax.
  apply assoc.
Qed.


Definition nat_trans_comp {C C' : precategory}
  (F G H: functor_data C C') 
  (a : nat_trans F G)
  (b : nat_trans G H): nat_trans F H :=
    tpair _ _ (is_nat_trans_comp a b).


(** *** The data of the functor precategory *)

Definition functor_precategory_data (C C' : precategory): precategory_data.
Proof.
  apply ( precategory_data_pair 
        (functor_precategory_ob_mor C C')).
  intro a. simpl.
  apply (nat_trans_id (pr1 a)).
  intros a b c f g.
  apply (nat_trans_comp _ _ _ f g).
Defined.

(** *** Above data forms a precategory *)

Lemma is_precategory_functor_precategory_data (C C' : precategory) :
   is_precategory (functor_precategory_data C C').
Proof.
  repeat split; simpl; intros.
  unfold identity.
  simpl.
  apply nat_trans_eq.
  intro x; simpl.
  apply id_left.
  
  apply nat_trans_eq.
  intro x; simpl.
  apply id_right.
  
  apply nat_trans_eq.
  intro x; simpl.
  apply assoc.
Qed.

Definition functor_precategory (C C' : precategory): precategory := 
  tpair _ _ (is_precategory_functor_precategory_data C C').

Notation "[ C , D ]" := (functor_precategory C D).

Lemma nat_trans_comp_pointwise (C C' : precategory)
  (F G H : ob [C, C']) (A : F --> G) (A' : G --> H) 
   (B : F --> H) : A ;; A' == B -> 
        forall a, pr1 A a ;; pr1 A' a == pr1 B a.
Proof.
  intros H' a.
(*  simpl in *. *)
  pathvia (pr1 (A ;; A') a).
  apply idpath.
  induction H'.
  apply idpath.
Defined.
  
  

(** Characterizing isomorphisms in the functor category *)

Lemma is_nat_trans_inv_from_pointwise_inv (C D : precategory)
  (F G : ob [C,D]) (A : F --> G) 
  (H : forall a : ob C, is_isomorphism (pr1 A a)) :
  is_nat_trans _ _ 
     (fun a : ob C => inv_from_iso (tpair _ _ (H a))).
Proof.
  unfold is_nat_trans.
  intros x x' f.
  apply pathsinv0.
  apply iso_inv_on_right.
  rewrite assoc.
  apply iso_inv_on_left.
  set (HA:= pr2 A).
  simpl in *.
  unfold is_nat_trans in HA.
  rewrite HA.
  apply idpath.
Qed.

Definition nat_trans_inv_from_pointwise_inv (C D : precategory)
  (F G : ob [C,D]) (A : F --> G) 
  (H : forall a : ob C, is_isomorphism (pr1 A a)) :
    G --> F := tpair _ _ (is_nat_trans_inv_from_pointwise_inv _ _ _ _ _ H).


Lemma functor_iso_if_pointwise_iso (C C' : precategory)
 (F G : ob [C, C']) (A : F --> G) : 
   (forall a : ob C, is_isomorphism (pr1 A a)) ->  
           is_isomorphism A .
Proof.
  intro H.
  simpl in *.
  exists (nat_trans_inv_from_pointwise_inv _ _ _ _ _ H).
  simpl; split; simpl.
  apply nat_trans_eq.
  intro x; simpl.
  apply (pr2 (H _)).
  apply nat_trans_eq.
  intro x; simpl.
  apply (pr2 (pr2 (H _))).
Qed.  

Definition functor_iso_from_pointwise_iso (C C' : precategory)
 (F G : ob [C, C']) (A : F --> G) 
   (H : forall a : ob C, is_isomorphism (pr1 A a)) : 
     iso F G := 
 tpair _ _ (functor_iso_if_pointwise_iso _ _ _ _ _  H).


Lemma is_functor_iso_pointwise_if_iso (C C' : precategory)
 (F G : ob [C, C']) (A : F --> G) : 
  is_isomorphism A -> 
       forall a : ob C, is_isomorphism (pr1 A a).  
Proof.
  intros H a.
  simpl in *.
  set (R := pr1 H).
  simpl in *.
  exists (R a).
(*  exists (pr1 H a).
  destruct H as [A' [H1 H2]].
  simpl in A'. exists (A' a).
*)
  unfold is_inverse_in_precat in *; simpl; split.
  set (H1' := nat_trans_eq_pointwise _ _ _ _ _ _ (pr1 (pr2 H))).
  simpl in H1'.
  apply H1'.
  apply (nat_trans_eq_pointwise _ _ _ _ _ _ (pr2 (pr2 H))).
Defined.


Definition functor_iso_pointwise_if_iso (C C' : precategory)
 (F G : ob [C, C']) (A : F --> G) 
  (H : is_isomorphism A) : 
     forall a : ob C, 
       iso (pr1 F a) (pr1 G a) := 
  fun a => tpair _ _ (is_functor_iso_pointwise_if_iso C C' F G A H a).
 
(*
Lemma functor_iso_pointwise_if_iso_on_idtoiso (C C' : precategory)
  (F G : ob [C, C']) (A : F == G) :
    forall a : ob C,
   precategory_fun_iso_pointwise_if_iso C C' F G (idtoiso F) a
    ==  toforallpaths 
  *)  

Definition pr1_pr1_functor_eq_from_functor_iso (C D : precategory)
    (H : is_category D) (F G : ob [C , D]) :
   iso F G -> pr1 (pr1 F) == pr1 (pr1 G).
Proof.
  intro A.
  apply funextsec.
  intro t.
  apply isotoid.
  assumption.
  apply (functor_iso_pointwise_if_iso _ _ _ _ A).
  apply (pr2 A).
Defined.




Lemma transport_of_functor_map_is_pointwise (C D : precategory) 
      (F0 G0 : ob C -> ob D)
    (F1 : forall a b : ob C, a --> b -> F0 a --> F0 b)
   (gamma : F0  == G0 ) 
    (a b : ob C) (f : a --> b) :
transportf (fun x : ob C -> ob D => 
            forall a0 b0 : ob  C, a0 --> b0 -> x a0 --> x b0)
           gamma  F1 a b f == 
transportf (fun TT : ob D => G0 a --> TT)
  (toforallpaths (fun _ : ob C => D) F0 G0 gamma b)
  (transportf (fun SS : ob D => SS --> F0 b)
     (toforallpaths (fun _ : ob C => D) F0 G0 gamma a) (F1 a b f)).
Proof.
  induction gamma.
  apply idpath.
Defined.


Lemma toforallpaths_funextsec : forall (T : UU) (P : T -> UU) (f g : forall t : T, P t)
          (h : forall t : T, f t == g t), 
            toforallpaths _  _ _ (funextsec _ _ _ h) == h.
Proof.
  intros T P f g h.
  set (H':= homotweqinvweq (weqtoforallpaths _ f g)).
  simpl in H'.
  apply H'.
Qed.


Definition pr1_functor_eq_from_functor_iso (C D : precategory)
    (H : is_category D) (F G : ob [C , D]) :
   iso F G -> pr1 F == pr1 G.
Proof.
  intro A.
  apply (total2_paths (pr1_pr1_functor_eq_from_functor_iso C D H F G A)).
  simpl in *.
  unfold pr1_pr1_functor_eq_from_functor_iso.
  simpl in *.
  apply funextsec.
  intro a.
  apply funextsec.
  intro b.
  apply funextsec.
  intro f.
  rewrite transport_of_functor_map_is_pointwise.
  rewrite toforallpaths_funextsec.
  set (H':= double_transport_idtoiso D _ _ _ _  
         (isotoid D H (functor_iso_pointwise_if_iso C D F G A (pr2 A) a))
         (isotoid D H (functor_iso_pointwise_if_iso C D F G A (pr2 A) b))
          (pr2 (pr1 F) a b f)).
          unfold double_transport in H'. 
  pathvia ((inv_from_iso
        (idtoiso
           (isotoid D H
              (functor_iso_pointwise_if_iso C D F G A (pr2 A) a)));;
      pr2 (pr1 F) a b f);;
     idtoiso
       (isotoid D H
          (functor_iso_pointwise_if_iso C D F G A (pr2 A) b))).
  apply H'.
  clear H'.
  rewrite idtoiso_isotoid.
  rewrite idtoiso_isotoid.
  destruct A as [A Aiso].
  simpl in *.
  pathvia 
    (inv_from_iso (functor_iso_pointwise_if_iso C D F G A Aiso a) ;;
       (A a ;; #G f)).
  rewrite <- assoc.
  apply maponpaths.
  apply (nat_trans_ax _ _ A).
  rewrite assoc.

  unfold functor_iso_pointwise_if_iso.
  unfold inv_from_iso.
  simpl in *.

  destruct Aiso as [A' AH].
  simpl in *.
  destruct AH as [A1 A2].
  rewrite (nat_trans_comp_pointwise _ _ _ _ _ _ _ _ A2).
  simpl.
  rewrite id_left.
  apply idpath.
Defined.

Definition functor_eq_from_functor_iso {C D : precategory}
    (H : is_category D) (F G : ob [C , D]) 
    (H' : iso F G) : F == G.
Proof.
  apply (functor_eq _ _ F G).
  apply pr1_functor_eq_from_functor_iso;
  assumption.
Defined.


Lemma idtoiso_compute_pointwise (C D : precategory) (F G : ob [C, D])
     (p : F == G) (a : ob C) :
  functor_iso_pointwise_if_iso C D F G (idtoiso p) (pr2 (idtoiso p)) a ==
idtoiso
  (toforallpaths (fun _ : ob C => D) (pr1 (pr1 F)) (pr1 (pr1 G))
     (base_paths (pr1 F) (pr1 G) (base_paths F G p)) a).
Proof.
  induction p.
  simpl.
  apply eq_iso. simpl. apply idpath.
Qed.


Lemma functor_eq_from_functor_iso_idtoiso (C D : precategory)
    (H : is_category D)
    (F G : ob [C, D]) (p : F == G) :
  functor_eq_from_functor_iso H F G (idtoiso p) == p.
Proof.
  simpl.
  apply functor_eq_eq_from_functor_ob_eq.
  unfold functor_eq_from_functor_iso.
  unfold functor_eq.
  simpl.
  rewrite base_total_path_fibr.
  unfold pr1_functor_eq_from_functor_iso.
  rewrite base_total_path_fibr.
  unfold pr1_pr1_functor_eq_from_functor_iso.
  
  apply (equal_transport_along_weq _ _   (weqtoforallpaths _ _ _ )).
  
  simpl.
  rewrite toforallpaths_funextsec.
  simpl.
  apply funextsec.
  intro a. 
  rewrite idtoiso_compute_pointwise.
  
  rewrite isotoid_idtoiso.
  apply idpath.
Qed.

Lemma idtoiso_functor_eq_from_functor_iso (C D : precategory)
    (H : is_category D)
    (F G : ob [C, D]) (gamma : iso F G) :
        idtoiso  (functor_eq_from_functor_iso H F G gamma) == gamma.
Proof.
  apply eq_iso.
  simpl.
  apply nat_trans_eq.
  intro a.
  set (H':= idtoiso_compute_pointwise C D F G (functor_eq_from_functor_iso H F G gamma) a).
  simpl in *.
  set (H2 := maponpaths (@pr1 _ _ ) H').
  simpl in H2.
  pathvia (pr1
       (idtoiso
          (toforallpaths (fun _ : ob C => D) (pr1 (pr1 F)) (pr1 (pr1 G))
             (base_paths (pr1 F) (pr1 G)
                (base_paths F G (functor_eq_from_functor_iso H F G gamma))) a))).
  apply H2. clear H2.
  unfold functor_eq_from_functor_iso.
  simpl.
  unfold functor_eq.
  rewrite base_total_path_fibr.
  unfold pr1_functor_eq_from_functor_iso.
  rewrite base_total_path_fibr.

  pathvia (pr1 (idtoiso
     (isotoid D H (functor_iso_pointwise_if_iso C D F G gamma (pr2 gamma) a)))).
  apply maponpaths.
  apply maponpaths.
  unfold pr1_pr1_functor_eq_from_functor_iso.
  rewrite toforallpaths_funextsec.
  apply idpath.
  rewrite idtoiso_isotoid.
  apply idpath.
Qed.

Lemma isweq_idtoiso_functorcat (C D : precategory) (H : is_category D) 
    (F G : ob [C, D]) :
   isweq (precat_paths_to_iso F G).
Proof.
  apply (gradth _ (functor_eq_from_functor_iso H F G)).
  apply functor_eq_from_functor_iso_idtoiso.
  apply idtoiso_functor_eq_from_functor_iso.
Qed.

Lemma is_category_functor_category (C D : precategory) (H : is_category D) :
   is_category [C, D].
Proof.
  intros F G.
  apply isweq_idtoiso_functorcat.
  apply H.
Qed.

