(** Ship builder *)

(** [coor] represents a coordination in the form of Letter-Number *)

exception Hitted of string

(** A [Ship] has coordinates that have possibly been hit. *)
module type Ship = sig

  (** [t] is the type of ships *)
  type t

  (** [size s] is number of coordinates in s. *)
  val size : t -> int

  (** [create lst] creates a ship with the coordinate list [lst]*)
  val create : (int * int) list -> t

  (** [hit coor s] is the ship [s] with the coordinate [coord] set to false.
      Raises: [Hitted] if coordinate has already been hit. *)
  val hit : int * int -> t -> unit

  (** [calive coor s] is true iff [coor] hasn't been hit.*)
  val calive : int * int -> t -> bool

  (** [alive s] is true if there exists a coordinate in ship [s] that is true.*)
  val alive: t -> bool

  (** [coordinates s] is the list of coordinates of [s]. *)
  val coordinates : t -> (int * int) list

  (** [health ship] is the number of alive coordinates left in the ship [ship]*)
  val health: t -> int

  (** [get_largest lst int] finds the length of the largest alive ship in [lst].
      Tail recursive. [int] should be zero. *)
  val get_largest: t list -> int -> int 

end

module ShipMaker : Ship with type t = ((int * int) * bool) list ref