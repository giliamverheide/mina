open Core_kernel
open Fold_lib
open Tuple_lib

module type S = sig
  type curve

  module Digest : sig
    type t [@@deriving sexp, eq, compare, yojson]

    val fold_bits : t -> bool Fold.t

    val fold : t -> bool Triple.t Fold.t

    val ( = ) : t -> t -> bool
  end

  module Params : sig
    type t = curve array
  end

  module State : sig
    type t = {triples_consumed: int; acc: curve; params: Params.t}

    val create : ?triples_consumed:int -> ?init:curve -> Params.t -> t

    val update_fold : t -> bool Triple.t Fold.t -> t

    val digest : t -> Digest.t

    val salt : Params.t -> string -> t
  end

  val hash_fold : State.t -> bool Triple.t Fold.t -> State.t

  val digest_fold : State.t -> bool Triple.t Fold.t -> Digest.t
end

module Make (Field : sig
  type t [@@deriving sexp, eq, compare]

  include Stringable.S with type t := t

  val fold_bits : t -> bool Fold.t

  val fold : t -> bool Triple.t Fold.t
end) (Curve : sig
  type t [@@deriving sexp]

  val to_affine_exn : t -> Field.t * Field.t

  val zero : t

  val ( + ) : t -> t -> t

  val negate : t -> t
end) : S with type curve := Curve.t and type Digest.t = Field.t
