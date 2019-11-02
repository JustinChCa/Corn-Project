open Ship
open Board

module type Player = sig 
  type t 

  val init_player: ShipMaker.t -> Board.t -> string -> t

  val dis_board: t -> unit

  val dis_name: t -> unit

  val is_alive: t -> unit

  val get_ships: t -> ShipMaker.t list


end

module PlayerMaker = struct 


  type t = {ships: ShipMaker.t list;
            board: Board.t;
            ships_alive: int;
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

  let update_ship t ship = 

    (** NOT DONE *)
    List.fold_left (fun accum el -> 
        if ShipMaker.alive el then accum+1 else accum) 0 t.ships



end 

