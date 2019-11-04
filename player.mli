open Ship
open Board

module type Player = sig 
  type t 

  (**[init_player ships board name] is a Player with a board [board], 
     ships [ships], and with a name [name] *)
  val init_player: ShipMaker.t list -> BoardMaker.t -> string -> t

  (**[get_name t] is the name of the player [t] *)
  val get_name: t -> string

  (**[is_alive t] checks whether player [t] is alive *)
  val is_alive: t -> bool

  (**[get_ships t] is the ships of player [t] *)
  val get_ships: t -> ShipMaker.t list

  (**[update_ship t ship] returns a copy of player [t] with an updated
     ship [ship] *)
  val update_ship: t -> ShipMaker.t -> t

  (**[get_board t] is the board of player [t] *)
  val get_board: t -> BoardMaker.t


end


module PlayerMaker : Player 

