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
    let rec find_ship lst  =
      match lst with 
      | [] -> []
      | h::t -> if (ShipMaker.compare h ship) = Ship.EQ then ship::t else h::(find_ship t)

    in

    let new_ships = find_ship t.ships in 
    let num_alive = List.fold_left (fun accum el -> if ShipMaker.alive el then accum+1 else accum) 0 new_ships in 
    {
      ships=new_ships;
      board=t.board;
      ships_alive=num_alive;
      name=t.name
    }



end 

