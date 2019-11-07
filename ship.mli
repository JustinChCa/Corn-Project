(** Ship builder *)

(** [coor] represents a coordination in the form of Letter-Number *)
type coor = int * int

exception Hitted
(** A [Ship] has coordinates that have possibly been hit. *)
module type Ship = sig

  (** [t] is the type of ships *)
  type t

  (** [size s] is number of coordinates in s. 
      [size empty] is 0.*)
  val size : t -> int

  (** [create lst] creates a ship with the coordinate list [lst]*)
  val create : coor list -> t

  (** [hit coord s] is the ship [s] with the coordinate [coord] set to false.
      Raises: [Hitted] if coordinate has already been hit*)
  val hit : coor -> t -> unit

  val calive : coor -> t -> bool

  (** [alive s] is true if there exists a coordinate in ship [s] that is true.*)
  val alive: t -> bool

  val coordinates : t -> coor list
end

module ShipMaker : Ship with type t = (coor * bool) list ref