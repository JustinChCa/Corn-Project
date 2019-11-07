open Ship
open Board

module type Player = sig 
  type t 

  val create : ShipMaker.t list -> BoardMaker.t -> string -> t

  val get_name: t -> string

  val alive: t -> bool

  val get_ships: t -> ShipMaker.t list

  val get_board: t -> BoardMaker.t

  val hit : t -> unit

end

module PlayerMaker = struct 
  type t = {ships: ShipMaker.t list;
            board: BoardMaker.t;
            name: string}

  let create ships board name = {
    ships= ships;
    board= board;
    name= name;
  }

  let alive player =
    List.exists (fun a -> ShipMaker.alive a) player.ships

  let get_ships t = t.ships

  let get_board t = t.board

  let get_name t = t.name


  let rec hit enemy = 
    try BoardMaker.hit (enemy.board) (read_int (), read_int ()) with
    | Missed (x,y)-> print_endline "You've already missed this spot. Try again";
      hit enemy
    | Hitted -> print_endline "You've already hit this spot. Try again";
      hit enemy

end 

