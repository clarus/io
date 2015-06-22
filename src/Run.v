Require Import Effect.
Require Import C.

(** A specification is an execution of a computation with explicit answers for
    the external calls. *)
Inductive t {E : Effect.t} : forall {A : Type}, C.t E A -> A -> Type :=
| Ret : forall {A} (x : A), t (C.Ret (E := E) A x) x
| Call : forall (c : Effect.command E) (answer : Effect.answer E c),
  t (C.Call (E := E) c) answer
| Let : forall {A B} {c_x : C.t E A} {x : A} {c_f : A -> C.t E B} {y : B},
  t c_x x -> t (c_f x) y -> t (C.Let A B c_x c_f) y
| ChooseLeft : forall {A} {c_x1 c_x2 : C.t E A} {x1 : A},
  t c_x1 x1 -> t (C.Choose A c_x1 c_x2) x1
| ChooseRight : forall {A} {c_x1 c_x2 : C.t E A} {x2 : A},
  t c_x2 x2 -> t (C.Choose A c_x1 c_x2) x2
| Join : forall {A B} {c_x : C.t E A} {x : A} {c_y : C.t E B} {y : B},
  t c_x x -> t c_y y -> t (C.Join A B c_x c_y) (x, y).

(** Run the let of a ret. *)
Definition let_ret {E A B} {v : A} {f : A -> C.t E B} {y : B}
  (run_f_v : t (f v) y) : t (C.Let _ _ (C.Ret _ v) f) y.
  eapply Let.
  - apply Ret.
  - exact run_f_v.
Defined.