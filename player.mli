open Ship
open Board

(** The [Player] module representing a player.*)

module type Player = sig 
  (** type [t] is the type of [Player]*)
  type t 

  (**[empty] is an empty player for the purposes of utilization by the
     Client Engne. *)
  val empty: t

  (**[create ships board name] is a Player with a board [board], 
     ships [ships], and with a name [name] *)
  val create : ShipMaker.t list -> BoardMaker.t -> string -> t

  (**[get_name t] is the name of the player [t] *)
  val get_name: t -> string

  (**[alive t] checks whether player [t] is alive *)
  val alive: t -> bool

  (**[alive_ships t] is how many of [t]'s ships are alive. *)
  val alive_ships: t -> int

  (**[get_ships t] is the ships of player [t] *)
  val get_ships: t -> ShipMaker.t list

  (**[get_board t] is the board of player [t] *)
  val get_board: t -> BoardMaker.t

  (**[hit t coor] is true iff the hit was successful and modifies [t].
      Raises [Hitted] if the [coor] as already been hit.
      Raises [Missed] if the [coor] as already been missed
      Raises [Invalid_argument] is [coor] is out of bounds.*)
  val hit: t -> int * int -> bool
end


module PlayerMaker : Player 

