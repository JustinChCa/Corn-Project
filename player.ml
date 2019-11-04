open Ship
open Board

module type Player = sig 
  type t 

  val init_player: ShipMaker.t list -> BoardMaker.t -> string -> t

  val get_name: t -> string

  val is_alive: t -> bool

  val get_ships: t -> ShipMaker.t list

  val update_ship: t -> ShipMaker.t -> t

  val get_board: t -> BoardMaker.t

end

module PlayerMaker = struct 

  type t = {ships: ShipMaker.t list;
            board: BoardMaker.t;
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

  let get_board t = t.board

  let get_name t = t.name

  let rec find_ship lst ship =
    match lst with 
    | [] -> []
    | h::t -> if (ShipMaker.compare h ship) = Ship.EQ 
      then ship::t else h::(find_ship t ship)

  let update_ship t ship = 
    let new_ships = find_ship t.ships ship in 
    let num_alive = List.fold_left (fun accum el -> 
        if ShipMaker.alive el then accum+1 else accum) 0 new_ships in 
    {
      ships=new_ships;
      board=t.board;
      ships_alive=num_alive;
      name=t.name
    }



end 

