open Ship
open Board

module type Player = sig 
  type t 

  val init_player: ShipMaker.t list -> BoardMaker.t -> string -> t

  val get_name: t -> string

  val is_alive: t -> bool

  val get_ships: t -> ShipMaker.t list

  val update_ships: t -> ShipMaker.t list -> unit

  val get_board: t -> BoardMaker.t

end

module PlayerMaker = struct 

  type t = {mutable ships: ShipMaker.t list;
            board: BoardMaker.t;
            mutable ships_alive: int;
            name: string
           }

  let init_player ships board name = {
    ships= ships;
    board= board;
    ships_alive= List.length ships;
    name= name
  }

  let is_alive t =
    if t.ships_alive = 0 then false else true

  let get_ships t = t.ships

  let get_board t = t.board

  let get_name t = t.name

  let update_ships t ships = 
    t.ships <- ships;
    let num_alive = List.fold_left (fun accum el -> 
        if ShipMaker.alive el then accum+1 else accum) 0 ships in
    t.ships_alive <- num_alive

end 

