(** Ship builder *)

(** [coor] represents a coordination in the form of Letter-Number *)
type coor = string

(** A [Ship] has coordinates that have possibly been hit. *)
module type Ship = sig

  (** [t] is the type of ships *)
  type t

  (** [taken] is the list of coordinates being used. *)
  val taken : coor list ref

  (** [empty] is an empty ship. *)
  val empty : t

  (** [is_empty s] is [true] iff [s] is empty. *)
  val is_empty : t -> bool

  (** [size s] is number of coordinates in s. 
      [size empty] is 0.*)
  val size : t -> int

  val insert: coor -> t -> t
  val remove: coor -> t -> t
  val create: coor list -> t
  val hit: coor -> t -> t
  val alive: t -> bool
end

module ShipMaker : 
  Ship with type t = (coor * bool) list