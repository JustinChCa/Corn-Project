open Ship
open Board

module type Player = sig 
  type t 


  (**[empty] is an empty player for the purposes of utilization by the
     Client Engne. *)
  val empty: t
  (**[init_player ships board name] is a Player with a board [board], 
     ships [ships], and with a name [name] *)
  val create : ShipMaker.t list -> BoardMaker.t -> string -> t

  (**[get_name t] is the name of the player [t] *)
  val get_name: t -> string

  (**[is_alive t] checks whether player [t] is alive *)
  val alive: t -> bool

  (**[get_ships t] is the ships of player [t] *)
  val get_ships: t -> ShipMaker.t list

  (**[get_board t] is the board of player [t] *)
  val get_board: t -> BoardMaker.t

  val hit: t -> int * int -> unit

end


module PlayerMaker : Player 

