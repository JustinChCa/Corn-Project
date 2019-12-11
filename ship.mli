(** The [Ship] module representing a ship. *)

(** [Hitted s] is raised when a given coordinate has already been hit. *)
exception Hitted of string

(** A [Ship] has coordinates that have possibly been hit. *)
module type Ship = sig
  (** AF: The list [((y1, x1), b1), ..., ((yn, xn), bn)] represents
        a ship with coordinates represent by the [(y, x)] pairs that
        may or may not been hit based on their [b] *)

  (** [t] is the type of ships *)
  type t

  (** [size ship] is number of coordinates in ship. *)
  val size : t -> int

  (** [create coor] creates a ship with the coordinate list [coor]*)
  val create : (int * int) list -> t

  (** [hit coor ship] is true with the ship [s] with the coordinate [coord] 
      set to false.
      Raises: [Hitted] if coordinate has already been hit. *)
  val hit : int * int -> t -> bool

  (** [calive coor ship] is true iff [coor] hasn't been hit in [ship].*)
  val calive : int * int -> t -> bool

  (** [alive ship] is true if there exists a coordinate in [ship] that is true.
  *)
  val alive: t -> bool

  (** [coordinates ship] is the list of coordinates of [ship]. *)
  val coordinates : t -> (int * int) list

  (** [health ship] is the number of alive coordinates left in [ship]*)
  val health: t -> int

  (** [get_largest lst int] finds the length of the largest alive ship in [lst].
      Tail recursive. [int] should be zero. *)
  val get_largest: t list -> int -> int 

  (** [ship_pos ship coor orient] adds [coor] to each element in [ship] and
      flips each element iff [orient] is false. *)
  val ship_pos: (int * int) list -> (int * int) -> bool -> (int * int) list
end

module ShipMaker : Ship with type t = ((int * int) * bool) list ref