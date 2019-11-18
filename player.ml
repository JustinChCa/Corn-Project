open Ship
open Board


module type Player = sig 
  type t 

  val empty: t

  val create : ShipMaker.t list -> BoardMaker.t -> string -> t

  val get_name: t -> string

  val alive: t -> bool

  val get_ships: t -> ShipMaker.t list

  val get_board: t -> BoardMaker.t

  val hit : t -> int * int -> unit

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

  let empty= 
    {
      ships=[ShipMaker.create [(1,1)]];
      board= BoardMaker.create 1 1;
      name="dummy";
    }

  let alive player =
    List.exists (fun a -> ShipMaker.alive a) player.ships

  let get_ships t = t.ships

  let get_board t = t.board

  let get_name t = t.name

  let hit enemy coor = 
    BoardMaker.hit (enemy.board) coor
end 

