(** Ship builder *)

(** [coor] represents a coordination in the form of Letter-Number *)
type coor = int*int
type compare = | EQ | GL
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

  (** [insert coor s] inserts coordinate [coor] into ship [s]. Does nothing
      if [coor] already in [s]. *)
  val insert: coor -> t -> t

  (** [remove coor s] removes the coordinate [coor] from ship [s]. Does
      nothing if [coor] already in [s]. *)
  val remove: coor -> t -> t

  (** [create lst] creates a ship with the coordinate list [lst]*)
  val create: coor list -> t

  (** [hit coord s] is the ship [s] with the coordinate [coord] set to false.*)
  val hit: coor -> t -> t

  (** [alive s] is true if there exists a coordinate in ship [s] that is true.*)
  val alive: t -> bool

  (** [compare s1 s2] returns EQ if and only if the first coordinates of [s1]
      and [s2] are equal, else returns GL. *)
  val compare: t -> t -> compare
end

module ShipMaker : 
  Ship with type t = (coor * bool) list