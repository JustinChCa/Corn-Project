(** Ship builder *)

(** [coor] represents a coordination in the form of Letter-Number *)
type coor = int * int

exception Hitted of string

(** A [Ship] has coordinates that have possibly been hit. *)
module type Ship = sig

  (** [t] is the type of ships *)
  type t

  (** [size s] is number of coordinates in s. *)
  val size : t -> int

  (** [create lst] creates a ship with the coordinate list [lst]*)
  val create : coor list -> t

  (** [hit coor s] is the ship [s] with the coordinate [coord] set to false.
      Raises: [Hitted] if coordinate has already been hit. *)
  val hit : coor -> t -> unit

  (** [calive coor s] is true iff [coor] hasn't been hit.*)
  val calive : coor -> t -> bool

  (** [alive s] is true if there exists a coordinate in ship [s] that is true.*)
  val alive: t -> bool

  (** [coordinates s] is the list of coordinates of [s]. *)
  val coordinates : t -> coor list
end

module ShipMaker : Ship with type t = (coor * bool) list ref